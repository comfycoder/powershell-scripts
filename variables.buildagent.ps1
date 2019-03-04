#**********************************************************
# Get Azure DevOps Build Agnet Information
#**********************************************************

Write-Host "Hello World from $Env:AGENT_NAME."

Write-Host "My ID is $env:AGENT_ID."

Write-Host "AGENT_WORKFOLDER contents:"
Get-ChildItem $env:AGENT_WORKFOLDER

Write-Host "AGENT_BUILDDIRECTORY contents:"
Get-ChildItem $env:AGENT_BUILDDIRECTORY

Write-Host "BUILD_SOURCESDIRECTORY contents:"
Get-ChildItem $env:BUILD_SOURCESDIRECTORY

Write-Host "Over and out."

