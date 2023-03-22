# Data-engineering-batch-processing-infrastructure
## About this project
This project contains a system which runs quartaly ingesting a large amount of data by pulling it from [Kaggle (US accidents)](https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents). The data is stored and pre-processes on Azure with the help of Spark. During this step, rows not having the weather condition set are removed and the different US states are grouped with their weather conditions. The aggregated data can later on be used for a machine learning application which is not covered in this repository.

Special about this project is that a part of the infrastructure for the pre-processing is created in a seperated resource group and teared down after it's use to save running costs. For more information about the tear down, have a look at [tearDownPipeline.sh](https://github.com/carolineRe13/Data-engineering-batch-processing-infrastructure/blob/main/devops/tearDownPipeline.sh).

## Running the project locally
- make sure `docker` and `docker-compose` are installed
- create kaggle.json file in a folder of your choice. (ex: $HOME/.kaggle/kaggle.json)
```
{
    "username": kaggle_username,
    "key": kaggle_key
}
```
- create `.env` file in root of project
- Add `KAGGLE_HOME="path/to/kaggle/folder"` to it
- `docker-compose up`

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
- Add a secret to the github repo with the name `AZURE_SUBSCRIPTION` and the value of the subscription id
- Add a secret to the github repo with the name `AZURE_RG` and the value of the resource group name
- Create [github token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  - It should have 'Repository permissions':
    - Read access to code and metadata
    - Read and Write access to actions and workflows
- Create a new secret in the keyvault with the name `webhook-trigger` and the value of the token you just created
- Create a new secret in the keyvalut with the name `GithubRepo` and the value of the repo (<username>/Data-engineering-batch-processing-infrastructure)

The first time you run the "Azure ARM" workflow it will fail as it creates resources that need to be added as secrets to github.
After the first run:
- Go to the ACR resource in the resource group
- Go to the "Access Keys" tab
- Add the following secrets to the github repo:
  - `ACR_ENDPOINT`: Login server
  - `ACR_USERNAME`: Username
  - `ACR_PASSWORD`: password

## Change number of spark worker nodes
You can change the number of spark worker nodes by passing a `workerCount` parameter to the containerInstance.bicep file. This requires a teardown and deploy of the pipeline.

## Trigger a pipeline run
You can use the github token created above in this command.
```
curl -i \
  -X POST \  
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/<username>/Data-engineering-batch-processing-infrastructure/actions/workflows/deployAndRunPipeline.yaml/dispatches \
  -d '{"ref":"main"}'
```

## Cancel a pipeline run
You can use the github token created above in this command.
```
curl -i \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/<username>/Data-engineering-batch-processing-infrastructure/actions/workflows/tearDownPipeline.yaml/dispatches \
  -d '{"ref":"main"}'
```
