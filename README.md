# Data-engineering-batch-processing-infrastructure

- create kaggle.json file in a folder of your choice. (ex: $HOME/.kaggle/kaggle.json)
```
{
    "username": kaggle_username,
    "key": kaggle_key
}
```

- create .env file in root of project
- Add `KAGGLE_HOME="path/to/kaggle/folder"` to it


## Deployment using github actions
az ad sp create-for-rbac --name "A_SERVICE_PRINCIPAL_NAME" --sdk-auth --role contributor --scopes /subscriptions/A_SUBSCIPTION_ID

az ad sp create-for-rbac --name "<name>" --sdk-auth --role 'custom contributor' --scopes /subscriptions/<subscription-id>

az ad sp create-for-rbac --name "test" --sdk-auth --role 'custom contributor' --scopes /subscriptions/2254675d-f031-4623-95b3-53948cbde732

You'll need to create a new role to assign to the github application.  
Base it on the contributor role and:
- Remove the `"Microsoft.Authorization/*/Write"` `NotAction` permission.
- Add the `"Microsoft.Resources/subscriptions/resourceGroups/write"` `Action` permission.


{
  "clientId": "fa9d5360-a725-476f-9525-c723309949a3",
  "clientSecret": "4F18Q~Gs9xZo6Ag_ZIEPzNFhTWw98ZTZ06QEhdAa",
  "subscriptionId": "2254675d-f031-4623-95b3-53948cbde732",
  "tenantId": "cbd1b406-5730-4839-956f-4be8c42b224e",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}