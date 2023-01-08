@description('location for all resources.')
param location string = resourceGroup().location

var projectName = 'DataEngineering'

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: '${projectName}KV'
  scope: resourceGroup()
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'DataEngineeringUSTrafficContainerRegistry'
  params: {
    location: location
    secret: kv.getSecret('container-pwd')
  }
}
/*
module containerInstance 'modules/containerInstance.bicep' = {
  name: 'DataEngineeringUSTrafficContainerGroup'
  params: {
    location: location
    secret: kv.getSecret('container-pwd')
  }
}
*/

