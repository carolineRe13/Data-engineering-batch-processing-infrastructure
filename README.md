# Data-engineering-batch-processing-infrastructure
## Running the project locally
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
- Create a new resource group
- Create a new keyvault in the resource group
  - update keyvault URI in constants.py file
- Create a new role to assign to the github application.  
  Base it on the contributor role and:
  - Remove the `"Microsoft.Authorization/*/Write"` `NotAction` permission.
  - Remove the `"Microsoft.Authorization/*/Delete"` `NotAction` permission.
  - Add the `"Microsoft.Resources/subscriptions/resourceGroups/write"` `Action` permission.
- Create a new service principal  
  `az ad sp create-for-rbac --name "<name>" --sdk-auth --role 'custom contributor' --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>`  
- Add a secret to the github repo with the name `AZURE_CREDENTIALS` and the value of the output from the above command 
- Create [github token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  - It should have 'Repository permissions':
    - Read access to code and metadata
    - Read and Write access to actions and workflows
- Create a new secret in the keyvault with the name `webhook-trigger` and the value of the token you just created
- Create a new secret in the keyvalut with the name `GithubRepo` and the value of the repo (<username>/Data-engineering-batch-processing-infrastructure)

## Trigger a pipeline run
You can use the github token created above in these commands.
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