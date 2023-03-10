@description('location for all resources.')
param location string = resourceGroup().location

var projectName = 'DataEngineering'

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: '${projectName}KV'
  scope: resourceGroup()
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' existing = {
  name: '${projectName}USTrafficVirtualNetwork/${projectName}USTrafficSubNet'
  scope: resourceGroup()
}

module containerInstance 'modules/containerInstance.bicep' = {
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
