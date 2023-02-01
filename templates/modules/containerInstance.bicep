@description('location for all resources.')
param location string = resourceGroup().location

@description('Name for the container group')
param name string

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'dataengineeringustrafficcontainerregistry.azurecr.io/ingestor:latest'
@description('Name for the instance')
param instanceName string = 'ingestor'

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

@description('Id from the subnet of the virtual network')
param subnetId string

@secure()
param secret string

param projectName string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: [
      {
        name: toLower(instanceName)
        properties: {
          image: image
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
      {
        name: 'spark-master'
        properties: {
          image: 'apache/spark:latest'
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          command: [
            '/bin/bash'
            '-c'
            '/opt/spark/sbin/start-master.sh && tail -f /opt/spark/logs/*'
          ]
          ports: [
            {
              port: 7077
              protocol: 'TCP'
            }
            {
              port: 8080
              protocol: 'TCP'
            }
          ]
          volumeMounts: [
            {
              name: 'spark-logs'
              mountPath: '/opt/spark/logs'
            }
          ]
        }
      }
      {
        name: 'spark-worker-1'
        properties: {
          image: 'apache/spark:latest'
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          command: [
            '/bin/bash'
            '-c'
            '/opt/spark/sbin/start-worker.sh --webui-port 8081 spark://spark-master:7077  && tail -f /opt/spark/logs/**'
          ]
          ports: [
            {
              port: 8081
              protocol: 'TCP'
            }
          ]
          volumeMounts: [
            {
              name: 'spark-logs'
              mountPath: '/opt/spark/logs'
            }
          ]
        }
      }
      {
        name: 'spark-worker-2'
        properties: {
          image: 'apache/spark:latest'
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          command: [
            '/bin/bash'
            '-c'
            '/opt/spark/sbin/start-worker.sh --webui-port 8082 spark://spark-master:7077  && tail -f /opt/spark/logs/**'
          ]
          ports: [
            {
              port: 8082
              protocol: 'TCP'
            }
          ]
          volumeMounts: [
            {
              name: 'spark-logs'
              mountPath: '/opt/spark/logs'
            }
          ]
        }
      }
    ]
    imageRegistryCredentials: [
      {
        username: 'DataEngineeringUSTrafficContainerRegistry'
        password: secret
        server: 'dataengineeringustrafficcontainerregistry.azurecr.io'
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    subnetIds: [
      {
        id: subnetId
      }
    ]
    volumes: [{
      name: 'spark-logs'
      azureFile: {
        shareName: 'spark-logs'
        storageAccountName: toLower('${projectName}data')
        storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', toLower('${projectName}data')), '2021-04-01').keys[0].value
      }
    }]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: toLower('${projectName}data')
  scope: resourceGroup()
}

@description('This is the built-in Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor')
resource storageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource blobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(storageAccount.id, containerGroup.id, storageBlobDataContributor.id)
  properties: {
    roleDefinitionId: storageBlobDataContributor.id
    principalId: containerGroup.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: '${projectName}KV'
  scope: resourceGroup()
}

@description('This is the built-in Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource keyVaultSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: keyVault
  name: guid(keyVault.id, containerGroup.id, keyVaultSecretsUser.id)
  properties: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: containerGroup.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
