az resource delete --resource-group $2 --name DataEngineeringContainerGroup --resource-type "Microsoft.ContainerInstance/containerGroups"
az role assignment list --scope /subscriptions/$1/resourcegroups/$2/providers/Microsoft.KeyVault/vaults/DataEngineeringKV --role /subscriptions/$1/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6 --query "[?contains(principalType, 'ServicePrincipal')].{id:id}" --out tsv | xargs az role assignment delete --ids
