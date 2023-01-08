@minLength(5)
@maxLength(50)
@description('container name')
param acrName string = 'DataEngineeringUSTrafficContainerRegistry'

@description('location for all resources.')
param location string = resourceGroup().location

@description('Azure Container Registry tier')
param acrSku string = 'Basic'

@secure()
param secret string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
