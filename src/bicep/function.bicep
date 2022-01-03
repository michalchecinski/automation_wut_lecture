@minLength(3)
@maxLength(24)
param functionStorageAccountName string

param location string = resourceGroup().location

param appInsightsName string

param functionAppName string

param hostingPlanName string

@minLength(3)
@maxLength(24)
param keyVaultName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: functionStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    enabled: true
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource accessKey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'access-key'
  parent: keyvault
  properties: {
    value: 'very-secret-access-key'
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: 'add'
  parent: keyvault
  properties: {
    accessPolicies: [
      {
        tenantId: functionApp.identity.tenantId
        objectId: functionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource functionAppAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${functionApp.name}/appsettings'
  properties: {
    AccessKey: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/${accessKey.name}/)'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
    WEBSITE_CONTENTSHARE: toLower(storageAccount.name)
  }
  dependsOn: [
    keyVaultAccessPolicy
  ]
}
