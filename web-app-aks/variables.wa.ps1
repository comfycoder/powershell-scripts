#**********************************************************
# Azure DevFunction App dotnet CLI variables
#**********************************************************

# Enter the name you wish to call your web app project
$WEB_APP_NAME = "MyWebApp"
Write-Verbose "WEB_APP_NAME: $WEB_APP_NAME" -Verbose

# Enter a local path in which to create your web app
$WEB_APP_PATH = "C:\srcDojo\$WEB_APP_NAME"
Write-Verbose "WEB_APP_PATH: $WEB_APP_PATH" -Verbose

#**********************************************************
# Docker image, tag, container variables
#**********************************************************

# Enter a name for your docker image
$IMAGE_NAME = "mywebapp"
Write-Verbose "IMAGE_NAME: $IMAGE_NAME" -Verbose

# Enter a tag to identify your image version
$IMAGE_TAG = "v1.0.0"
Write-Verbose "IMAGE_TAG: $IMAGE_TAG" -Verbose

# Combine the image and tag names to define your container name
$CONTAINER_NAME = $IMAGE_NAME + ":" + $IMAGE_TAG
Write-Verbose "CONTAINER_NAME: $CONTAINER_NAME" -Verbose

#**********************************************************
# Azure Container Registry variables
#**********************************************************

# Enter the name of your remote private container registry (ACR)
$ACR_NAME = "acrcnmycontainers"
Write-Verbose "ACR_NAME: $ACR_NAME" -Verbose

# Enter the name of the Azure Resource Group where your
# remote private container registry (ACR) is located
$ACR_RG_NAME = "RG-CN-MyContainers"
Write-Verbose "ACR_RG_NAME: $ACR_RG_NAME" -Verbose

#**********************************************************
# Kubernetes variables
#**********************************************************

# Name for your web app kubernetes deployment/service
$K8S_APP_NAME = "$WEB_APP_NAME-dvlp".ToLower()
Write-Verbose "K8S_APP_NAME: $K8S_APP_NAME" -Verbose

# Set the KUBECONFIG environment variable
[System.Environment]::SetEnvironmentVariable("KUBECONFIG", $env:USERPROFILE +"\.kube\config" , "User")

# Relative path for kube config file
$KUBE_CONFIG_PATH = (Join-Path "$env:USERPROFILE" "\.kube\config")
Write-Verbose "KUBE_CONFIG_PATH: $KUBE_CONFIG_PATH" -Verbose

#**********************************************************
# Azure Function App Resource Manager variables
#**********************************************************

# Enter a short name for you web app (8-character or less)
# This is used to generate name for other resources you
# will be creating in this process
$WEB_APP_SHORT_NAME = "MyApp"
Write-Verbose "WEB_APP_SHORT_NAME: $WEB_APP_SHORT_NAME" -Verbose

# Name of the Azure Resource Group where your
# remote private container registry (ACR) is located
$WEB_APP_RG_NAME = "RG-CN-$WEB_APP_SHORT_NAME"
Write-Verbose "WEB_APP_RG_NAME: $WEB_APP_RG_NAME" -Verbose

$WEB_APP_LOCATION = "eastus2"
Write-Verbose "WEB_APP_LOCATION: $WEB_APP_LOCATION" -Verbose

# URL of your webb app once deployed to Azure
$WEB_APP_URL = "https://$WEB_APP_NAME.azurewebsites.net".ToLower()
Write-Verbose "WEB_APP_URL: $WEB_APP_URL" -Verbose

# Name of your Web App as deployed to Azure
$WEB_APP_NAME = "AS-CN-$WEB_APP_SHORT_NAME"
Write-Verbose "WEB_APP_NAME: $WEB_APP_NAME" -Verbose

# Name of the App Service Plan used to host your web app in Azure
$ASP_NAME = "ASP-CN-$WEB_APP_SHORT_NAME"
Write-Verbose "ASP_NAME: $ASP_NAME" -Verbose

# Name of the App Insights instance used to monitor your web app in Azure
$AIS_NAME = "AIS-CN-$WEB_APP_SHORT_NAME"
Write-Verbose "AIS_NAME: $AIS_NAME" -Verbose

# Input properties used when deploying App Insights for your web app
$AIS_PROPS = "props.json"
'{
    "Application_Type": "web",
    "Flow_Type": null,
    "Request_Source": "IbizaWebAppExtensionCreate",
    "HockeyAppId": null,
    "SamplingPercentage": null
}' | Out-File $AIS_PROPS


