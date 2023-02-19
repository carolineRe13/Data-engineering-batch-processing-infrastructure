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
az ad sp create-for-rbac --name "<name>" --sdk-auth --role 'custom contributor' --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>

You'll need to create a new role to assign to the github application.  
Base it on the contributor role and:
- Remove the `"Microsoft.Authorization/*/Write"` `NotAction` permission.
- Add the `"Microsoft.Resources/subscriptions/resourceGroups/write"` `Action` permission.

## Trigger a pipeline run
- create github token
```
curl -i \
  -X POST \  
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/<username>/Data-engineering-batch-processing-infrastructure/actions/workflows/deployAndRunPipeline.yaml/dispatches \
  -d '{"ref":"main"}'
```

```
curl -i \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/<username>/Data-engineering-batch-processing-infrastructure/actions/workflows/tearDownPipeline.yaml/dispatches \
  -d '{"ref":"main"}'
```