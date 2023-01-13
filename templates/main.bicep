@description('location for all resources.')
param location string = resourceGroup().location

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'DataEngineeringUSTrafficContainerRegistry'
  params: {
    location: location
  }
}

