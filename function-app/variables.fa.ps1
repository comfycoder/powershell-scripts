#**********************************************************
# Azure DevFunction App dotnet CLI variables
#**********************************************************

$FUNC_APP_NAME = "MyFunctionProj"
Write-Verbose "FUNC_APP_NAME: $FUNC_APP_NAME" -Verbose

$FUNC_APP_PATH = "C:\srcDojo\$FUNC_APP_NAME"
Write-Verbose "FUNC_APP_PATH: $FUNC_APP_PATH" -Verbose

$FUNC_APP_TRIGGER_NAME = "MyHttpTrigger"
Write-Verbose "FUNC_APP_TRIGGER_NAME: $FUNC_APP_TRIGGER_NAME" -Verbose

$FUNC_APP_TRIGGER_TEMPLATE = "HttpTrigger"
Write-Verbose "FUNC_APP_TRIGGER_TEMPLATE: $FUNC_APP_TRIGGER_TEMPLATE" -Verbose

#**********************************************************
# Docker image, tag, container variables
#**********************************************************

$IMAGE_NAME = "myfuncapp"
Write-Verbose "IMAGE_NAME: $IMAGE_NAME" -Verbose

$IMAGE_TAG = "v1.0.0"
Write-Verbose "IMAGE_TAG: $IMAGE_TAG" -Verbose

$CONTAINER_NAME = $IMAGE_NAME + ":" + $IMAGE_TAG
Write-Verbose "CONTAINER_NAME: $CONTAINER_NAME" -Verbose
# "myfuncapp:v1.0.0"

#**********************************************************
# Azure Container Registry variables
#**********************************************************

$ACR_NAME = "acrcnmycontainers"
Write-Verbose "ACR_NAME: $ACR_NAME" -Verbose

$ACR_RG_NAME = "RG-CN-MyContainers"
Write-Verbose "ACR_RG_NAME: $ACR_RG_NAME" -Verbose

#**********************************************************
# Azure Function App Resource Manager variables
#**********************************************************

$FUNC_APP_SHORT_NAME = "MyFunc"
Write-Verbose "FUNC_APP_SHORT_NAME: $FUNC_APP_SHORT_NAME" -Verbose

$FUNC_APP_RG_NAME = "RG-CN-$FUNC_APP_SHORT_NAME"
Write-Verbose "FUNC_APP_RG_NAME: $FUNC_APP_RG_NAME" -Verbose

$FUNC_APP_LOCATION = "eastus2"
Write-Verbose "FUNC_APP_LOCATION: $FUNC_APP_LOCATION" -Verbose

$FUNC_APP_URL = "https://$FUNC_APP_NAME.azurewebsites.net/api/MyHttpTrigger?name=Bob"
Write-Verbose "FUNC_APP_URL: $FUNC_APP_URL" -Verbose

$FUNC_UAMI = "UAMI-$FUNC_APP_SHORT_NAME"
Write-Verbose "FUNC_UAMI: $FUNC_UAMI" -Verbose

$FUNC_APP_NAME = "FA-CN-$FUNC_APP_SHORT_NAME"
Write-Verbose "FUNC_APP_NAME: $FUNC_APP_NAME" -Verbose

$STORAGE_ACCOUNT_NAME = "sacn$FUNC_APP_SHORT_NAME".ToLower()
Write-Verbose "STORAGE_ACCOUNT_NAME: $STORAGE_ACCOUNT_NAME" -Verbose

$ASP_NAME = "ASP-CN-$FUNC_APP_SHORT_NAME"
Write-Verbose "ASP_NAME: $ASP_NAME" -Verbose

$AIS_NAME = "AIS-CN-$FUNC_APP_SHORT_NAME"
Write-Verbose "AIS_NAME: $AIS_NAME" -Verbose

$AIS_PROPS = "props.json"
'{
    "Application_Type": "web",
    "Flow_Type": null,
    "Request_Source": "IbizaWebAppExtensionCreate",
    "HockeyAppId": null,
    "SamplingPercentage": null
}' | Out-File $AIS_PROPS

$KV_NAME = "kv-cn-myfunc"
Write-Verbose "KV_NAME: $KV_NAME" -Verbose

$KV_RG_NAME = "RG-CN-Enigma" 
Write-Verbose "KV_RG_NAME: $KV_RG_NAME" -Verbose