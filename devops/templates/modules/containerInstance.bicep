@description('location for all resources.')
param location string = resourceGroup().location

@description('Name for the container group')
param name string

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'dataengineeringustrafficcontainerregistry.azurecr.io/pipeline:latest'

param sparkMasterImage string = 'dataengineeringustrafficcontainerregistry.azurecr.io/spark-master:latest'

param sparkWorkerImage string = 'dataengineeringustrafficcontainerregistry.azurecr.io/spark-worker:latest'

@description('Name for the instance')
param instanceName string = 'pipeline'

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The number of CPU cores to allocate to the spark worker containers. (per container)')
param workerCpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The amount of memory to allocate to the spark worker containers in gigabytes. (per container)')
param workerMemoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'OnFailure'

@description('Id from the subnet of the virtual network')
param subnetId string

@secure()
param secret string

param projectName string

param workerCount int = 2

var workers = [for index in range(0, workerCount): {
  name: 'spark-worker-${index}'
  properties: {
    image: sparkWorkerImage
    resources: {
      requests: {
        cpu: workerCpuCores
        memoryInGB: workerMemoryInGb
      }
    }
    environmentVariables: [
      {
        name: 'WEBUI_PORT'
        value: 8180 + index
      }
      { 
        name: 'MASTER_URL'
        value: 'localhost:7077'
      }
      {
        name: 'WORKER_PORT'
        value: 38080 + index
      }
    ]
    ports: [
      {
        port: 8180 + index
        protocol: 'TCP'
      }
      {
        port: 38080 + index
        protocol: 'TCP'
      }
    ]
    volumeMounts: [
      {
        name: 'spark-logs'
        mountPath: '/opt/spark/logs'
      }
      {
        name: 'spark-data'
        mountPath: '/data'
        readOnly: true
      }
      {
        name: 'spark-tmp'
        mountPath: '/tmp'
      }
    ]
  }
}]

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: concat([
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
          environmentVariables: [
            {
              name: 'ENVIRONMENT'
              value: 'Production'
            }
          ]
          volumeMounts: [
            {
              name: 'spark-data'
              mountPath: '/data'
            }
          ]
        }
      }
      {
        name: 'spark-master'
        properties: {
          image: sparkMasterImage
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
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
            {
              name: 'spark-data'
              mountPath: '/data'
              readOnly: true
            }
            {
              name: 'spark-tmp'
              mountPath: '/tmp'
            }
          ]
        }
      }
    ], workers)
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: 8080
          protocol: 'TCP'
        }
      ]
    }
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
    volumes: [
      {
        name: 'spark-logs'
        azureFile: {
          shareName: 'spark-logs'
          storageAccountName: toLower('${projectName}data')
          storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', toLower('${projectName}data')), '2021-04-01').keys[0].value
        }
      }
      {
        name: 'spark-data'
        azureFile: {
          shareName: 'spark-data'
          storageAccountName: toLower('${projectName}data')
          storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', toLower('${projectName}data')), '2021-04-01').keys[0].value
        }
      }
      {
        name: 'spark-tmp'
        azureFile: {
          shareName: 'spark-tmp'
          storageAccountName: toLower('${projectName}data')
          storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', toLower('${projectName}data')), '2021-04-01').keys[0].value
        }
      }
    ]
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
