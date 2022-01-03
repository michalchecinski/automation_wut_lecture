@minLength(3)
@maxLength(24)
param keyVaultName string

param location string = resourceGroup().location


resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: []
  }
}
