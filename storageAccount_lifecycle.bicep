//App Service Plan name
param planName string
//Days in whole number
param days int
//Typically, leave this to the default
param location string = resourceGroup().location
/*@allowed([
  'nonprod'
  'prod'
])
param environmentType string*/

var storageAccountName = '${planName}storage'
var lifecycleName = '${planName}storage'

//var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_RAGRS' : 'Standard_RAGRS'
var storageAccountSkuName = 'Standard_RAGRS'

targetScope = 'resourceGroup'

//Makes a storage ccount
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
}

//Makes a storage lifecycle so storage is automatically deleted after int days
resource name_lifecycle 'Microsoft.Storage/storageAccounts/managementPolicies@2021-08-01' = {
    name: 'default'
    parent: storageaccount
    properties: {
      policy: {
        rules: [
          {
            definition: {
              actions: {
                baseBlob: {
                  delete: {
                    daysAfterModificationGreaterThan: days
                  }
                }
                snapshot: {
                  delete: {
                    daysAfterCreationGreaterThan: days
                  }
                }
                version: {
                  delete: {
                    daysAfterCreationGreaterThan: days
                }
              }
              }
              filters: {
                blobTypes: [
                  'blockBlob'
                ]
              }            
            }
            name: lifecycleName
            type: 'Lifecycle'
            enabled: true
          }
        ]
    }
  }
}
