import os
import requests
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, EnvironmentCredential

KV_URI = 'https://dataengineeringkv.vault.azure.net/'


def call_teardown_workflow():
    credential = ChainedTokenCredential(DefaultAzureCredential(), EnvironmentCredential())

    client = SecretClient(vault_url=KV_URI, credential=credential)

    # Kaggle
    github_token = client.get_secret("webhook-trigger")
    github_repo = client.get_secret("GithubRepo")

    url = f"https://api.github.com/repos/{github_repo.value}/actions/workflows/tearDownPipeline.yaml/dispatches"

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {github_token.value}",
        "X-GitHub-Api-Version": "2022-11-28"
    }

    requests.post(url, json = {"ref":"main"}, headers=headers)


if __name__ == "__main__":
    if os.environ["ENVIRONMENT"] != "Development":
        print("Production environment, calling teardown workflow")
        call_teardown_workflow()
    else:
        print("Development environment, skipping teardown workflow")
