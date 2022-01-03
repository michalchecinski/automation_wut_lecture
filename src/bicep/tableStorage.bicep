@minLength(3)
@maxLength(24)
param storageName string

param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@minLength(3)
@maxLength(63)
param tableName string


resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource storageTableService 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = {
  name: 'default'
  parent: storage

  resource storageTable 'tables@2021-06-01' = {
    name: tableName
  }
}
