function LogInfo
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$message
    )

    # Writes a warning to log preceded by "WARNING: "
    Write-Verbose "$($message)" -Verbose
}

function LogWarning
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$message
    )

    # Writes a warning to log preceded by "WARNING: "
    Write-Warning "$($env:WarningMessage) $($message)"
}

function LogError
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$message
    )

    # Set error Message
    Write-Host "$("##vso[task.setvariable variable=ErrorMessage]") $($args[0])"

    # Writes an error to the build summary and to the log in red text
    Write-Host  "$("##vso[task.LogIssue type=error;]") $("the task.LogIssue Azure Pipelines logging command reported that") $($env:ErrorMessage)"

    exit 1
}