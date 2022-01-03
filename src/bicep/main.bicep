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

@minLength(3)
@maxLength(24)
param functionStorageAccountName string

param functionAppName string

param appInsightsName string

param hostingPlanName string

@minLength(3)
@maxLength(24)
param keyVaultName string


module tableStorageModule './tableStorage.bicep' = {
  name: 'tableStorageDeploy'
  params: {
    storageName: storageName
    tableName: tableName
    skuName: skuName
    location: location
  }
}

module keyVaultModule './keyVault.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    keyVaultName: keyVaultName
  }
}


module funcModule './function.bicep' = {
  name: 'functionDeploy'
  params: {
    appInsightsName: appInsightsName
    functionAppName: functionAppName
    hostingPlanName: hostingPlanName
    functionStorageAccountName: functionStorageAccountName
    location: location
    keyVaultName: keyVaultName
  }
  dependsOn: [
    keyVaultModule
  ]
}
