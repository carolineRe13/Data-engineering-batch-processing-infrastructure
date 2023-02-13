@description('location for all resources.')
param location string = 'westus'

var projectName = 'DataEngineering'

targetScope = 'subscription'

resource staticResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectName
  location: location
}

resource pipelineResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectName
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: '${projectName}KV'
  scope: staticResourceGroup
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' existing = {
  name: '${projectName}USTrafficVirtualNetwork/${projectName}USTrafficSubNet'
  scope: staticResourceGroup
}

module containerInstance 'modules/containerInstance.bicep' = {
  scope: pipelineResourceGroup
  name: 'DataEngineeringContainerGroup'
  params: {
    location: location
    secret: kv.getSecret('container-pwd')
    subnetId: subNet.id
    projectName: projectName
    restartPolicy: 'Never'
    name: '${projectName}ContainerGroup'
  }
}
