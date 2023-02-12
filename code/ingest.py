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


def upload_blob(credential, file, blob_name):
    blob_client = BlobClient(account_url="https://dataengineeringdata.blob.core.windows.net/", container_name="data", blob_name=blob_name, credential=credential)
    with open(file, "rb") as data:
        blob_client.upload_blob(data)


def setup_kaggle(credential):
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


def upload_dataset_to_blob_storage(credential):
    today = date.today()
    # storage account
    upload_blob(credential, "us-accidents.zip", f"us-accidents-{today}.zip")

    with zipfile.ZipFile("us-accidents.zip", 'r') as zip_ref:
        zip_ref.extractall("us-accidents")
        zip_ref.extractall("data")

    for file in os.listdir("us-accidents"):
        if file.endswith(".csv"):
            upload_blob(credential, "us-accidents/" + file, file.replace(".csv", f"-{today}.csv"))


if __name__ == "__main__":
    credential = ChainedTokenCredential(DefaultAzureCredential(), EnvironmentCredential())

    # authenticate to Kaggle
    setup_kaggle(credential)
    download_dataset()

    upload_dataset_to_blob_storage(credential)
