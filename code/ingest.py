import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from datetime import datetime, timedelta
from azure.storage.fileshare import ShareServiceClient, generate_account_sas, ResourceTypes, AccountSasPermissions

# get Kaggle API token from the KeyVault
# keyVaultName = os.environ["KEY_VAULT_NAME"]
keyVaultName = "dataengineeringkv"
KVUri = "https://{keyVaultName}.vault.azure.net"

kaggle_folder = ".kaggle"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KVUri, credential=credential)

# Kaggle
kaggle_username = client.get_secret("KaggleUsername")
kaggle_key = client.get_secret("KaggleKey")
kaggleData = {
    "username": kaggle_username,
    "key": kaggle_key
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
api.dataset_download_file('sobhanmoosavi/us-accidents',
                              'US_Accidents_Dec21_updated.zip', path='./')



# storage account
stroage_key = client.get_secret("StorageKey")
stroage_name= client.get_secret("StorageName")

sas_token = generate_account_sas(
    account_name=stroage_name,
    account_key=stroage_key,
    resource_types=ResourceTypes(service=True),
    permission=AccountSasPermissions(read=True),
    expiry=datetime.utcnow() + timedelta(hours=1)
)

file_client = ShareServiceClient(account_url="https://" + stroage_name + ".file.core.windows.net", credential=sas_token)

with open("./US_Accidents_Dec21_updated.zip", "rb") as source_file:
    file_client.upload_file(source_file)