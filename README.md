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
You'll need to create a new role to assign to the github application.  
Base it on the contributor role and:
- Remove the `"Microsoft.Authorization/*/Write"` `NotAction` permission.
- Add the `"Microsoft.Resources/subscriptions/resourceGroups/write"` `Action` permission.
