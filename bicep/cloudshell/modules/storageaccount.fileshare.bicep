param stName string
param fsName string


//if cloudShell then deploy fileservice and fileshare
resource fs 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  name: '${stName}/default'
}

resource fsshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = {
  parent: fs
  name: fsName
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols:'SMB'
    shareQuota: 6
  }
}
