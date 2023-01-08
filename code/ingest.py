import os
from kaggle.api.kaggle_api_extended import KaggleApi
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from datetime import datetime, timedelta
from azure.storage.fileshare import ShareServiceClient, generate_account_sas, ResourceTypes, AccountSasPermissions

# get Kaggle API token from the KeyVault
# keyVaultName = os.environ["KEY_VAULT_NAME"]
keyVaultName = "DataEngineeringKV"
KVUri = f"https://{keyVaultName}.vault.azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KVUri, credential=credential)

# Kaggle
os.env['KAGGLE_USERNAME'] = client.get_secret("KaggleUsername")
os.env['KAGGLE_KEY'] = client.get_secret("KaggleKey")

# storage account
stroage_key = client.get_secret("StorageKey")
stroage_name= client.get_secret("StorageName")

# authenticate to Kaggle
api = KaggleApi()
api.authenticate()

# download kaggle dataset
api.dataset_download_file('sobhanmoosavi/us-accidents',
                              'US_Accidents_Dec21_updated.zip', path='./')

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