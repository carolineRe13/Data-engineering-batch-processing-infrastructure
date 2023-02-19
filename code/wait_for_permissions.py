import os
from time import sleep
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, EnvironmentCredential
from azure.core.exceptions import HttpResponseError

KV_URI = 'https://dataengineeringkv.vault.azure.net/'
MAX_RETRIES = 10
RETRY_DELAY = 5


def access_secret():
    credential = ChainedTokenCredential(DefaultAzureCredential(), EnvironmentCredential())

    client = SecretClient(vault_url=KV_URI, credential=credential)

    # Kaggle
    client.get_secret("KaggleUsername")


def try_access_secret():
    retries = 0
    while retries < MAX_RETRIES:
        try:
            access_secret()
            return
        except HttpResponseError as e:
            retries += 1
            sleep(RETRY_DELAY ^ retries) # exponential backoff

    raise Exception("Could not access secret")


if __name__ == "__main__":
    if os.environ["ENVIRONMENT"] != "Development":
        print("Production environment, waiting for permissions")
        try_access_secret()
    else:
        print("Development environment, skipping secret access")
