# Before you begin - make sure you're logged in to Azure using the azure CLI
az login

# Enter your Azure subscription name here
$SUBSCRIPTION_NAME = "Enter Your Azure Subscription Name Here"

Write-Verbose "Set the default Azure subscription" -Verbose
az account set --subscription "$SUBSCRIPTION_NAME"

$SUBSCRIPTION_ID = $(az account show --query id -o tsv)
Write-Verbose "SUBSCRIPTION_ID: $SUBSCRIPTION_ID" -Verbose

$SUBSCRIPTION_NAME = $(az account show --query name -o tsv)
Write-Verbose "SUBSCRIPTION_NAME: $SUBSCRIPTION_NAME" -Verbose

$USER_NAME = $(az account show --query user.name -o tsv)
Write-Verbose "Service Principal Name or ID: $USER_NAME" -Verbose

$TENANT_ID = $(az account show --query tenantId -o tsv)
Write-Verbose "TENANT_ID: $TENANT_ID" -Verbose

Write-Verbose "Get the directory when the main script is executing" -Verbose
$SCRIPT_DIRECTORY = ($pwd).path
Write-Verbose "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY" -Verbose
