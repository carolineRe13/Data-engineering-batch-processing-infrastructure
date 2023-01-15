@description('location for all resources.')
param location string = resourceGroup().location

var projectName = 'DataEngineering'

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: '${projectName}USTrafficVirtualNetwork'
  params: {
    location: location
    virtualNetworkName: 'DataEngineeringUSTrafficVirtualNetwork'
    subnetName: '${projectName}USTrafficSubNet'
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: '${projectName}USTrafficStorageAccount'
  params: {
    location: location
    virtualNetworkId: virtualNetwork.outputs.subnetId
    projectName: projectName
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: '${projectName}USTrafficContainerRegistry'
  params: {
    location: location
  }
}
