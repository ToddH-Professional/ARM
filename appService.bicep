// This App Service Plan must be in the App Service Environments.
param appServicePlanName string
//Resource Group for app
param appServicePlanResourceGroupname string  
// Typically leave this to this default value.
param location string = resourceGroup().location  

// This becomes the first part in your url. It must be unique among all other apps that exist in the App Service Environment.
@description('The name of the app service.  Must be unique')
var appServiceName = '' 
var appServicePlan = resourceId(appServicePlanResourceGroupname, 'Microsoft.Web/serverfarms', appServicePlanName)

//Makes the WebApp
resource WebApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan
    hostingEnvironmentProfile: {
      id: reference(appServicePlan, '2021-03-01').hostingEnvironmentProfile.id
    }
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      use32BitWorkerProcess: false
    }
    httpsOnly: true
  }
}

resource WebAppConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${WebApp.name}/web'
  properties: {
    metadata: [
      { // This is part of enabling dotnet core.
        name: 'CURRENT_STACK'
        value: 'dotnet'
      }
    ]
    ftpsState: 'Disabled'
  }
}
// create user assigned managed identity
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${appServiceName}-mi'
  location: resourceGroup().location
}

output webAppName string = WebApp.name
