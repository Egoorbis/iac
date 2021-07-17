param name string
param envParameters object
param location string
param tags object

resource st 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  sku: {
    name: envParameters.sku.name
  }
  kind: envParameters.kind
  location: location
  tags: tags
  properties: {
    encryption: {
      services: {
        file:{
          keyType:'Account'
          enabled:true
        }
        blob:{
          keyType:'Account'
          enabled:true
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      keyvaultproperties: {}
      identity: {}
    }
    networkAcls: {
      bypass: 'AzureServices'
      resourceAccessRules: []
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    accessTier: envParameters.properties.accessTier
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: envParameters.properties.allowBlobPublicAccess
    minimumTlsVersion: envParameters.properties.minimumTlsVersion
  }
}

/*if cloudShell then deploy fileservice and fileshare
resource fs 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = if (cloudshell) {
  parent: st
  name: 'default'
}

resource fsshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = if (cloudshell) {
  parent: fs
  name: 'cloudshell'
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols:'SMB'
    shareQuota: 6
  }
}
*/

output storageAccountName string = st.id
