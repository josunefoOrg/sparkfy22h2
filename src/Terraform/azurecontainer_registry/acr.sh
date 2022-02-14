#!/bin/bash

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az acr create --resource-group $resourceGroupName --name $registryName --identity $userAssignedManagedIdentityId --key-encryption-key $customerManagedKeyId --sku $sku --admin-enabled $adminEnabled --default-action $defaultAction

if $enableSystemIdentity == true;
then
    az acr identity assign --identities [system] --name $registryName
fi
