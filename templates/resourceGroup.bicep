targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-dataEngineeringUSTraffic'
  location: 'westeurope'
}
