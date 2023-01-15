@description('location for all resources.')
param location string = resourceGroup().location

var projectName = 'DataEngineering'

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: 'DataEngineeringUSTrafficVirtualNetwork'
  params: {
    location: location
    virtualNetworkName: 'DataEngineeringUSTrafficVirtualNetwork'
    subnetName: 'DataEngineeringUSTrafficSubNet'
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'DataEngineeringUSTrafficStorageAccount'
  params: {
    location: location
    virtualNetworkId: virtualNetwork.outputs.subnetId
    projectName: projectName
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'DataEngineeringUSTrafficContainerRegistry'
  params: {
    location: location
  }
}
