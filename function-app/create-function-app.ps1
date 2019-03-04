# https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image

. (Join-Path $SCRIPT_DIRECTORY "variables.fa.ps1")

Set-Location "C:\"

New-Item -ItemType Directory -Force -Path $FUNC_APP_PATH

Set-Location $FUNC_APP_PATH

func init --name "$FUNC_APP_NAME" --docker --worker-runtime "dotnet" --source-control true --force

func new --name $FUNC_APP_TRIGGER_NAME --template $FUNC_APP_TRIGGER_TEMPLATE

# Build the containerized application
docker build -t "$CONTAINER_NAME" .

# Run the containerized application
docker run -p 8081:80 -it "$CONTAINER_NAME"

# Test the containerized application is working:
Start-Process "http://localhost:8081/api/MyHttpTrigger?name=Dennis"



# log in to our container registry
az acr login -n "$ACR_NAME" -g "$ACR_RG_NAME"

# Get the login server name
$LOGIN_SERVER = az acr show -n "$ACR_NAME" --query loginServer --output tsv

# See the images we have - should have samplewebapp:v2
docker image ls

# Prep image for remote container registry
docker tag $CONTAINER_NAME $LOGIN_SERVER/$CONTAINER_NAME

docker images

# Push the image to our Azure Container Registry
docker push $LOGIN_SERVER/$CONTAINER_NAME

# view the images in our ACR
az acr repository list -n "$ACR_NAME" -o table

# view the tags for the samplewebapp repository
az acr repository show-tags -n "$ACR_NAME" --repository "$IMAGE_NAME" -o table







# Create Resource Group for Function App resources
az group create -n $FUNC_APP_RG_NAME -l $FUNC_APP_LOCATION

az storage account create -n "$STORAGE_ACCOUNT_NAME" -l "$FUNC_APP_LOCATION" -g "$FUNC_APP_RG_NAME" `
    --sku "Standard_LRS" --access-tier "Hot" --bypass "None" --default-action "Allow" `
  --encryption-services blob queue --https-only true --kind "StorageV2"

# Create Application Service Plan
az appservice plan create --name "$ASP_NAME" --resource-group "$FUNC_APP_RG_NAME" --sku B1 --is-linux 

# Create Function App
# az functionapp create --name "$FUNC_APP_NAME" --storage-account "$STORAGE_ACCOUNT_NAME" `
#     --resource-group "$FUNC_APP_RG_NAME" --plan "$ASP_NAME" `
#     --deployment-container-image-name "$LOGIN_SERVER/$CONTAINER_NAME"


# Creat Application Insights
az resource create `
    --name "$AIS_NAME" `
    --resource-group "$FUNC_APP_RG_NAME" `
    --resource-type "microsoft.insights/components" `
    --location "eastus" `
    --properties "@$AIS_PROPS"

$AIS_KEY = az resource show -n "$AIS_NAME" -g "$FUNC_APP_RG_NAME"  `
    --resource-type "microsoft.insights/components" `
    --query "properties.InstrumentationKey" -o tsv

az functionapp create `
    --name "$FUNC_APP_NAME" `
    --resource-group "$FUNC_APP_RG_NAME" `
    --storage-account "$STORAGE_ACCOUNT_NAME" `
    --plan "$ASP_NAME" `
    --os-type "Linux" `
    --runtime dotnet `
    --app-insights "$AIS_NAME" `
    --app-insights-key "$AIS_KEY" 


$STORAGE_CONNECTION_STRING = $(az storage account show-connection-string `
    --resource-group "$FUNC_APP_RG_NAME" --name "$STORAGE_ACCOUNT_NAME" `
    --query connectionString --output tsv)

# https://azure.github.io/AppService/2018/09/24/Announcing-Bring-your-own-Storage-to-App-Service.html
# https://github.com/rramachand21/appsvcdemobyos
    
az functionapp config appsettings set --name "$FUNC_APP_NAME" `
    --resource-group "$FUNC_APP_RG_NAME" `
    --settings "AzureWebJobsDashboard=$STORAGE_CONNECTION_STRING" `
               "AzureWebJobsStorage=$STORAGE_CONNECTION_STRING"

$ACR_CONTAINER_IMAGE = "$LOGIN_SERVER/$CONTAINER_NAME"

az functionapp config container set `
    --name "$FUNC_APP_NAME" `
    --resource-group "$FUNC_APP_RG_NAME" `
    --docker-custom-image-name "$ACR_CONTAINER_IMAGE"

# Test the Function App
Start-Process "$FUNC_APP_URL"

# https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-cli
# Create a User Assigned Managed Identity
az identity create -n "$FUNC_UAMI" -g "$FUNC_APP_RG_NAME" 

# $UAI_RESOURCE_ID = $(az identity create -n "$FUNC_UAMI" -g "$FUNC_APP_RG_NAME" --query id --output tsv)


# https://docs.microsoft.com/en-us/cli/azure/functionapp/identity?view=azure-cli-latest#az-functionapp-identity-assign
# https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity
# Assign User Assigned Managed Identity to Function App
# Does not work yet: az functionapp identity assign -n "$FUNC_APP_NAME" -g "$FUNC_APP_RG_NAME" --ids "$UAI_RESOURCE_ID"
# Add Managed System Identity
az functionapp identity assign -n "$FUNC_APP_NAME" -g "$FUNC_APP_RG_NAME"



az keyvault create --name "$KV_NAME" --resource-group "$KV_RG_NAME" `
    --enabled-for-deployment true --enabled-for-disk-encryption true --enabled-for-template-deployment true `
    --sku "premium"

az functionapp identity


# az storage account create -n "sacnmyfuncapp" -l "eastus2" -g "RG-CN-MyApps" --sku Standard_LRS `
#     --access-tier "Hot" --bypass "None" --default-action "Allow" `
#     --encryption-services blob queue --https-only true --kind "StorageV2"

# az appservice plan create --name "ASP-CN-MyFuncApp" --resource-group "RG-CN-MyApps" --sku B1 --is-linux

# # Create Function App
# az functionapp create --name "FA-CN-MyFuncApp" --storage-account "sacnmyfuncapp" `
#     --resource-group "RG-CN-MyApps" --plan "ASP-CN-MyFuncApp" `
#     --deployment-container-image-name "acrcnmycontainers.azurecr.io/myfuncapp:v1.0.0"