@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of virtual network.')
param virtualNetworkName string

@description('Name of subnet.')
param subnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

output subnetId string = resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
