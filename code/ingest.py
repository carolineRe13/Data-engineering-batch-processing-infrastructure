import json
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, EnvironmentCredential
from azure.storage.blob import BlobClient
from datetime import date
import zipfile

KV_URI = 'https://dataengineeringkv.vault.azure.net/'
KAGGLE_FOLDER = ".kaggle"
KAGGLE_TOKEN_FILE = "kaggle.json"
DATASET_NAME = "sobhanmoosavi/us-accidents"


def setup_kaggle():
    # check if kaggle.json exists
    if (os.path.exists(os.path.join(KAGGLE_FOLDER, KAGGLE_TOKEN_FILE))):
        return

    credential = ChainedTokenCredential(DefaultAzureCredential(), EnvironmentCredential())

    client = SecretClient(vault_url=KV_URI, credential=credential)

    # Kaggle
    kaggle_username = client.get_secret("KaggleUsername")
    kaggle_key = client.get_secret("KaggleKey")
    kaggleData = {
        "username": kaggle_username.value,
        "key": kaggle_key.value
    }

    json_object = json.dumps(kaggleData, indent=4)

    if not os.path.exists(KAGGLE_FOLDER):
        os.makedirs(KAGGLE_FOLDER)

    with open(os.path.join(KAGGLE_FOLDER, KAGGLE_TOKEN_FILE), "w+") as outfile:
        outfile.write(json_object)


def download_dataset():
    from kaggle.api.kaggle_api_extended import KaggleApi # here as it looks for the kaggle.json file on import
    api = KaggleApi()
    api.authenticate()

    # download kaggle dataset
    api.dataset_download_files(DATASET_NAME)


def unpack_dataset_to_shared_data_folder():
    with zipfile.ZipFile("us-accidents.zip", 'r') as zip_ref:
        zip_ref.extractall("../data")


if __name__ == "__main__":
    # authenticate to Kaggle
    setup_kaggle()
    download_dataset()

    unpack_dataset_to_shared_data_folder()
