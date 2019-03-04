param
(
    [Parameter(Mandatory = $true)]
    [string] $armSPSecret
)

#**********************************************************
# Requested By
#**********************************************************

Write-Verbose "Requested By: $env:RELEASE_REQUESTEDFOREMAIL"

#**********************************************************
# Get PowerSchell Script Execution Path
#**********************************************************

Write-Verbose "Get the directory where the main script is executing" -Verbose
$SCRIPT_DIRECTORY = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Write-Verbose "Script Directory: $SCRIPT_DIRECTORY" -Verbose

#**********************************************************
# Get Azure DevOps Logging Methods
#**********************************************************

. (Join-Path $SCRIPT_DIRECTORY "logging.ps1")

#**********************************************************
# Log into Azure using RM Service Principal
#**********************************************************

$TENANT_ID = "$env:TENANT_ID"
Write-Verbose "TENANT_ID: $TENANT_ID" -Verbose

$ARM_SP_APP_NAME = "$env:ARM_SP_APP_NAME"
Write-Verbose "ARM_SP_APP_NAME: $ARM_SP_APP_NAME" -Verbose

$ARM_SP_APP_ID_URI = "http://$ARM_SP_APP_NAME"
Write-Verbose "ARM_SP_APP_ID_URI: $ARM_SP_APP_ID_URI" -Verbose

try {
    Write-Verbose "Log into Azure using DevOps Service Principal" -Verbose
    az login --service-principal -u "$ARM_SP_APP_ID_URI" `
      -p "$armSPSecret" -t "$TENANT_ID"
}
catch {
    $ERROR_MESSAGE = $_.Exception.Message
    LogError $ERROR_MESSAGE
    Write-Verbose "Error while logging into Azure using DevOps service principal: " -Verbose
    Write-Error -Message "ERROR: $ERROR_MESSAGE" -ErrorAction Stop
}

$SUBSCRIPTION_ID = $(az account show --query id -o tsv)
Write-Verbose "SUBSCRIPTION_ID: $SUBSCRIPTION_ID" -Verbose

$SUBSCRIPTION_NAME = $(az account show --query name -o tsv)
Write-Verbose "SUBSCRIPTION_NAME: $SUBSCRIPTION_NAME" -Verbose

$USER_NAME = $(az account show --query user.name -o tsv)
Write-Verbose "Service Principal Name or ID: $USER_NAME" -Verbose

#**********************************************************
# Get Azure DevOps Variables
#**********************************************************

. (Join-Path $SCRIPT_DIRECTORY "variables.ps1")

#**********************************************************
# Execute Custom PowerShell Child Scripts here...
#**********************************************************

try {
    
    # . (Join-Path $SCRIPT_DIRECTORY "build-agent-info.ps1")
}
catch {
    $ERROR_MESSAGE = $_.Exception.Message
    Write-Verbose "Error while loading or running supporting PowerShell Scripts: " -Verbose
    Write-Error "ERROR: $ERROR_MESSAGE" -Verbose
}

#**********************************************************
# Execute Custom PowerShell Cleanup Tasks here...
#**********************************************************