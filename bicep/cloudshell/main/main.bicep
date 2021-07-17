/*
Deploy a cloud shell account to management scope
*/
targetScope = 'managementGroup'

// Load parameters objects from parameters file
param envParameters object
param naming object

// Add creationDate parameter 
param creationDate object = {
  'CreationDate': utcNow('dd/MM/yyyy')
}

// Create resource group and storage account name based on envParameters and naming specified in parameters file
var rgName = '${envParameters.environment}-${envParameters.unit}-${naming.resourceGroup}-cloudshell'
var stName = '${envParameters.environment}${envParameters.unit}${naming.storageAccount}cloudshell'
var fsName = 'cloudshell'

// Deploy resource group to subscription scope
module rg_deploy '../modules/rg.bicep' = {
  name: 'deployment-${rgName}'
  scope: subscription(envParameters.subId)
  params: {
    name: rgName
    tags: union(creationDate, envParameters.tags)
    location: envParameters.location
  }
}

// Deploy storage account to resource group
module cs_deploy '../modules/storageaccount.bicep' = {
  name: 'deployment-${stName}'
  dependsOn: [
    rg_deploy
  ]
  scope: resourceGroup(envParameters.subId, rgName)
  params: {
    name: stName
    tags: union(creationDate, envParameters.tags, envParameters.service.cloudshell.tags)
    location: envParameters.location
    envParameters: envParameters.service.cloudshell
  }
}

module csfs_deploy '../modules/storageaccount.fileshare.bicep' = {
  name: 'deployment-${stName}-fileshare'
  dependsOn: [
    cs_deploy
  ]
  scope: resourceGroup(envParameters.subId, rgName)
  params: {
    stName: stName
    fsName: fsName
  }
}

output storageAccountName string = cs_deploy.outputs.storageAccountName
