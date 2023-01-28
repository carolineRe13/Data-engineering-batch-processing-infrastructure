import json
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from datetime import datetime, timedelta
from azure.storage.fileshare import ShareFileClient
from azure.storage.blob import BlobClient
from datetime import date
import zipfile

# get Kaggle API token from the KeyVault
# keyVaultName = os.environ["KEY_VAULT_NAME"]
KVUri = 'https://dataengineeringkv.vault.azure.net/'

kaggle_folder = ".kaggle"

credential = DefaultAzureCredential()

# just for local 
# credential = ChainedTokenCredential(new DefaultAzureCredential(), new EnvironmentCredential())

client = SecretClient(vault_url=KVUri, credential=credential)

# Kaggle
kaggle_username = client.get_secret("KaggleUsername")
kaggle_key = client.get_secret("KaggleKey")
kaggleData = {
    "username": kaggle_username.value,
    "key": kaggle_key.value
}

json_object = json.dumps(kaggleData, indent=4)

if not os.path.exists(kaggle_folder):
   os.makedirs(kaggle_folder)

print(os.path.abspath(kaggle_folder + "/kaggle.json")) 
with open(kaggle_folder + "/kaggle.json", "w+") as outfile:
    outfile.write(json_object)

# authenticate to Kaggle
from kaggle.api.kaggle_api_extended import KaggleApi
api = KaggleApi()
api.authenticate()

# download kaggle dataset
api.dataset_download_files('sobhanmoosavi/us-accidents')

# storage account
blob_name = f"us-accidents-{date.today()}.zip"
blob_client = BlobClient(account_url="https://dataengineeringdata.blob.core.windows.net/", container_name="data", blob_name=blob_name, credential=credential)

with open("us-accidents.zip", "rb") as data:
    blob_client.upload_blob(data)

with zipfile.ZipFile("us-accidents.zip", 'r') as zip_ref:
    zip_ref.extractall("us-accidents")

for file in os.listdir("us-accidents"):
    if file.endswith(".csv"):
        print(file)
        blob_client = BlobClient(account_url="https://dataengineeringdata.blob.core.windows.net/", container_name="data", blob_name=f"{file}{date.today()}", credential=credential)
        with open("us-accidents/" + file, "rb") as data:
            blob_client.upload_blob(data)