<#
	.NOTES
		==============================================================================================
		Copyright(c) Microsoft Corporation. All rights reserved.

		File:		Set-AkvSecrets.ps1

		Purpose:	Set Storage Accounts Key Secrets

		Version: 	3.0.0.0 - 1st November 2020
		==============================================================================================

		DISCLAIMER
		==============================================================================================
		This script is not supported under any Microsoft standard support program or service.

		This script is provided AS IS without warranty of any kind.
		Microsoft further disclaims all implied warranties including, without limitation, any
		implied warranties of merchantability or of fitness for a particular purpose.

		The entire risk arising out of the use or performance of the script
		and documentation remains with you. In no event shall Microsoft, its authors,
		or anyone else involved in the creation, production, or delivery of the
		script be liable for any damages whatsoever (including, without limitation,
		damages for loss of business profits, business interruption, loss of business
		information, or other pecuniary loss) arising out of the use of or inability
		to use the sample scripts or documentation, even if Microsoft has been
		advised of the possibility of such damages.

		IMPORTANT
		==============================================================================================
		This script uses or is used to either create or sets passwords and secrets.
		All coded passwords or secrests supplied from input files must be created and provided by the customer.
		Ensure all passwords used by any script are generated and provided by the customer
		==============================================================================================

	.SYNOPSIS
		Set Storage Accounts Key Secrets.

	.DESCRIPTION
		Set Storage Accounts Key Secrets.

		Deployment steps of the script are outlined below.
		1) Set Azure KeyVault Parameters
		2) Set Storage Accounts Parameters
		3) Create Azure KeyVault Secret

	.PARAMETER keyVaultName
		Specify the Azure KeyVault Name parameter.

	.PARAMETER storageAccountName
		Specify the Storage Account Name output parameter.

	.PARAMETER storageAccountResourceId
		Specify the Storage Account Resource Id output parameter.

	.PARAMETER storageAccountResourceGroup
		Specify the Storage Account Resource Group output parameter.

	.PARAMETER storageAccountAccessKey
		Specify the Storage Account Access Key output parameter.

    .PARAMETER storageAccountPrimaryBlobEndpoint
		Specify the Storage Account Primary Blob output parameter.

 

	.EXAMPLE
		Default:
		C:\PS>.\Set-AkvSecrets.ps1
			-keyVaultName "$(keyVaultName)"
			-storageAccountName "$(storageAccountName)"
			-storageAccountResourceId "$(storageAccountResourceId)"
			-storageAccountResourceGroup "$(storageAccountResourceGroup)"
			-storageAccountAccessKey "$(storageAccountAccessKey)"
			-storageAccountPrimaryBlobEndpoint "$(storageAccountPrimaryBlobEndpoint)"
#>

#Requires -Module Az.KeyVault

[CmdletBinding()]
param
(
	[Parameter(Mandatory = $true)]
	[string]$keyVaultName,

	[Parameter(Mandatory = $false)]
	[string]$storageAccountName,

	[Parameter(Mandatory = $false)]
	[string]$storageAccountResourceId,

	[Parameter(Mandatory = $false)]
	[string]$storageAccountResourceGroup,

	[Parameter(Mandatory = $false)]
	[string]$storageAccountAccessKey,

	[Parameter(Mandatory = $false)]
	[string]$storageAccountPrimaryBlobEndpoint	
)

#region - KeyVault Parameters
if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['keyVaultName']))
{
	Write-Output "KeyVault Name: $keyVaultName"
	$kvSecretParameters = @{ }

	#region - Storage Accounts Parameters
	if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['storageAccountName']))
	{
		Write-Output "Storage Account Name: $storageAccountName"
		$kvSecretParameters.Add("StorageAccount-Name-$($storageAccountName)", $($storageAccountName))
	}
	else
	{
		Write-Output "Storage Account Name: []"
	}

	if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['storageAccountResourceId']))
	{
		Write-Output "Storage Account ResourceId: $storageAccountResourceId"
		$kvSecretParameters.Add("StorageAccount-ResourceId-$($storageAccountName)", $($storageAccountResourceId))
	}
	else
	{
		Write-Output "Storage Account ResourceId: []"
	}

	if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['storageAccountResourceGroup']))
	{
		Write-Output "Storage Account ResourceGroup: $storageAccountResourceGroup"
		$kvSecretParameters.Add("StorageAccount-ResourceGroup-$($storageAccountName)", $($storageAccountResourceGroup))
	}
	else
	{
		Write-Output "Storage Account ResourceGroup: []"
	}

	if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['storageAccountAccessKey']))
	{
		Write-Output "Storage Account AccessKey: $storageAccountAccessKey"
		$kvSecretParameters.Add("StorageAccount-AccessKey-$($storageAccountName)", $($storageAccountAccessKey))
	}
	else
	{
		Write-Output "Storage Account AccessKey []"
	}

	if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters['storageAccountPrimaryBlobEndpoint']))
	{
		Write-Output "Storage Account PrimaryBlob: $storageAccountPrimaryBlobEndpoint"
		$kvSecretParameters.Add("StorageAccount-PrimaryBlob-$($storageAccountName)", $($storageAccountPrimaryBlobEndpoint))
	}
	else
	{
		Write-Output "Storage Account AccessKey []"
	}	
	#endregion

	#region - Set Azure KeyVault Secret
	$kvSecretParameters.Keys | ForEach-Object {
		$key = $psitem
		$value = $kvSecretParameters.Item($psitem)

		if (-not [string]::IsNullOrWhiteSpace($value))
		{
			Write-Output "KeyVault Secret: $key : $value"
			$value = $kvSecretParameters.Item($psitem)
			$paramSetAzKeyVaultSecret = @{
				VaultName   = $keyVaultName
				Name        = $key
				SecretValue = (ConvertTo-SecureString $value -AsPlainText -Force)
				Verbose     = $true
				ErrorAction = 'SilentlyContinue'
			}
			Set-AzKeyVaultSecret @paramSetAzKeyVaultSecret
		}
		else
		{
			Write-Output "KeyVault Secret: $key - []"
		}
	}
	#endregion
}
else
{
	Write-Output "KeyVault Name: []"
}
#endregion