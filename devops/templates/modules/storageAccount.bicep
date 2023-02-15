@description('location for all resources.')
param location string = resourceGroup().location

@description('virtual network.')
param virtualNetworkId string

param projectName string


resource rStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower('${projectName}data')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: virtualNetworkId
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: rStorageAccount
  name: 'default'
}

resource sparkLogsFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileServices
  name: 'spark-logs'
}

resource dataFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileServices
  name: 'spark-data'
}

resource tmpFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileServices
  name: 'spark-tmp'
}
