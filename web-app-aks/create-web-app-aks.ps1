#**********************************************************
# Get this script's execution path
#**********************************************************

$SCRIPT_DIRECTORY = ($pwd).path
Write-Verbose "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY" -Verbose

#**********************************************************
# Web App variables
#**********************************************************

. (Join-Path $SCRIPT_DIRECTORY "variables.wa.ps1")

#**********************************************************
# Create New ASP.NET Core Web MVC Project
#**********************************************************

# Change directory to the root of your "C" drive
Set-Location "C:\"

# Create the target folder location for your web app
New-Item -ItemType Directory -Force -Path $WEB_APP_PATH

# Change directory to the target folder location for your web app
Set-Location $WEB_APP_PATH

# Check the version of your ASP.NET Core dotnet SDK
# Make sure it is at least 2.2.104
dotnet --version

# dotnet new mvc --help

# Create a new ASP.NET Core MVC Web App
dotnet new mvc

# Open the web app in a new instance of VS Code
code .

# Perform the following steps:

<#
    1. You should have already open the web app project in a new VS Code instance
    2. On the keyboard, type Ctrl+Shift+P
       The command pallet appears
    3. Type "Docker", and the Docker commands appear.
    4. Select "Docker: Add Docker Files to Workstace".
       A list of platform types appear.
    5. Select "ASP.NET Core".
       A list of operating systems appear.
    6. Select "Linux".
       You are asked, "What port does your app listen on?", and port 80 is specified.
    7. Press the "Enter" key to confirm.
       The VS Code Docker extension adds two files, ".dockerignore" and "Dockerfile" 
       to the root of the web project.
#>

# Once you have added the Docker files to your web app
# you are ready to continue with the next steps

#**********************************************************
# Build container locally and run it
#**********************************************************

# Build the containerized application
docker build -t "$CONTAINER_NAME" .

# Show the history of an image in tabular format
docker image history "$CONTAINER_NAME"

# Show the history of an image in json format
docker image history "$CONTAINER_NAME" --format "{{json . }}"

# Run the containerized application in a web server
# using the integrated terminal to provide richer feedback information
# Maps the container internally exposed port 80 to external port 8081 
# when the app runs in the seb server
# docker run --interactive --publish 8081:80 "$CONTAINER_NAME"
docker run -it -p 8081:80 "$CONTAINER_NAME"

<#
NOTE: If you get an error like the following:

C:\Program Files\Docker\Docker\Resources\bin\docker.exe: Error response from daemon: 
driver failed programming external connectivity on endpoint suspicious_noyce 
(e8e31482ed24c1c88112ae1d951fcb1c92da4029d549c238af6e873c90374df5): Bind for 0.0.0.0:8081 failed: 
port is already allocated.

Run the following two commands in succession:

# Stop all containers:
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

Retry the previous docker run step above.

#>

# Test the containerized application is working:
# Open a browser to "http://localhost:8081"

# Shutdown the docker web server:
# On your keyboard, press Ctrl+C to stop running the docker image

# Stop all containers:
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Run the containerized application in a in a web server in a separate process
# which enables you to run additional commands after the web server starts
# Maps the container internally exposed port 80 to external port 8081 
# when the app runs in the seb server
# docker run --detach --publish 8081:80 "$CONTAINER_NAME"
docker run -d -p 8081:80 "$CONTAINER_NAME"

# Test the containerized application is working:
Start-Process "http://localhost:8081"

#**********************************************************
# Log into your remote private container registry (ACR)
#**********************************************************

# log in to your remote private container registry (ACR)
# az acr login -n "$ACR_NAME" -g "$ACR_RG_NAME"
az acr login -n "$ACR_NAME" 

# Get the login server name for your remote private container registry (ACR)
$LOGIN_SERVER = az acr show -n "$ACR_NAME" --query loginServer --output tsv
Write-Verbose "LOGIN_SERVER: $LOGIN_SERVER" -Verbose

#**********************************************************
# Examine you local docker images
#**********************************************************

# Show a list of local images
docker images
# Look for the name of your app name (REPOSITORY) and its tag name (TAG)

# Show the new local image
docker images "$CONTAINER_NAME"
# You should see only information for you app 

#**********************************************************
# Push image to your remote private container registry (ACR)
#**********************************************************

# Prep image for your private remote container registry (ACR)
docker tag "$CONTAINER_NAME" "$LOGIN_SERVER/$CONTAINER_NAME"

# Show the local newly preped image
docker images "$LOGIN_SERVER/$CONTAINER_NAME"
# You should see only information for you app, which now includes
# your private remote container registry (ACR) name prefix

# Push the locally preped image to your private remote container registry (ACR)
docker push $LOGIN_SERVER/$CONTAINER_NAME
<#
You should see something like the following:
The push refers to repository [acrcnmycontainers.azurecr.io/mywebapp]
660d06d7d393: Pushed
1c92f2caa4e7: Mounted from helloaks
54f6ca5d7337: Mounted from helloaks
1ca10d2d857b: Mounted from helloaks
f4b4d3f852f9: Mounted from helloaks
3c816b4ead84: Mounted from helloaks
v1.0.0: digest: sha256:d0a80629651e588b89f27357e512d275c311822893bec524719671655a39f506 size: 1580
#>

# View the images in your private remote container registry (ACR)
az acr repository list -n "$ACR_NAME" -o table
# You should see you image in the list

# View the tags for the container repository
az acr repository show-tags -n "$ACR_NAME" --repository "$IMAGE_NAME" -o table
# You should see your image tag in the list

#**********************************************************
# Deploy container to local kubernetes instance
#**********************************************************

$KUBERNETES_PATH = (Join-Path $WEB_APP_PATH "Kubernetes")
Write-Verbose "KUBERNETES_PATH: $KUBERNETES_PATH" -Verbose

# Create the target folder location for your web app
New-Item -ItemType Directory -Force -Path $KUBERNETES_PATH

Set-Location "$KUBERNETES_PATH"

$K8S_MANIFEST_TEMPLATE_PATH = (Join-Path $SCRIPT_DIRECTORY "deploy-app.tokenized.yaml")
Write-Verbose "K8S_MANIFEST_TEMPLATE_PATH: $K8S_MANIFEST_TEMPLATE_PATH" -Verbose

$K8S_MANIFEST_PATH = (Join-Path $KUBERNETES_PATH "deploy-app.yaml")
Write-Verbose "K8S_MANIFEST_PATH: $K8S_MANIFEST_PATH" -Verbose

Copy-Item "$K8S_MANIFEST_TEMPLATE_PATH" -Destination "$K8S_MANIFEST_PATH"

((Get-Content -path "$K8S_MANIFEST_PATH" -Raw) `
    -replace "__K8S_APP_NAME__", "$K8S_APP_NAME") `
    | Set-Content -Path "$K8S_MANIFEST_PATH"

((Get-Content -path "$K8S_MANIFEST_PATH" -Raw) `
    -replace "__RESOURCE_IMAGE_NAME__", "$CONTAINER_NAME") `
    | Set-Content -Path "$K8S_MANIFEST_PATH"

# Ensure that Kubernetes is enabled in your Docker settings
<#
NOTE: If not, installed, you may receive the following error when you try to
use your local docker kubernetes context:
Unable to connect to the server: dial tcp [::1]:8080: connectex: 
No connection could be made because the target machine actively refused it.
#>

# Make your local docker kubernetes local instance the current configuration context
kubectl config use-context docker-for-desktop
# You should ss the message: "Switched to context "docker-for-desktop"."

# Verify you have set the current context to you local kubernetes instance
kubectl config current-context 
# You should see: "docker-for-desktop"

# Check we have kubectl (should have if we've installed docker for windows)
kubectl version --short
<#
You should see something like the following:
Client Version: v1.10.11
Server Version: v1.10.11
#>

# Get the nodes on your local kubernetes instance
kubectl get nodes
<#
You should see something like the following:
docker-for-desktop   Ready     master    4m        v1.10.11
#>

# You have now verified that local docker kubernetes is up and running

# Install the kubernetes dashboard
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml
# kubectl proxy

# Deploy you web app to your local docker kubernetes instance
# kubectl apply -f "$K8S_MANIFEST_PATH"

kubectl run "$K8S_APP_NAME" --image="$CONTAINER_NAME" --port=80
<#
You should see something like the following:
deployment.apps "mywebapp-dvlp" created
#>

# Check the status of your deployment
kubectl get deployments --field-selector metadata.name="$K8S_APP_NAME"
<#
You should see your deployment name as in the following:
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
mywebapp-dvlp   1         1         1            1           36s
#>

# Check the status of your pods
kubectl get pods
<#
You should see an enty that indicates successful deployment of the pod itself, like:
NAME                             READY     STATUS    RESTARTS   AGE
kubeaspnetapp-7dbddb8bcd-hwxfr   1/1       Running   0          15m
mywebapp-dvlp-6f5d47d548-bvv4n   1/1       Running   0          1m
NOTE: all pods will have a randomly assigned suffix
#>

# Check the status of your services
kubectl get services
<#
NOTE: This may takes a bit before the services show, 
so please retry until you see something like the following:
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   1h
Note that the service does not appear as it is not publicly exposed
#>

# Describe the services
kubectl describe services
<#
You should see something like the following:
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP:                10.96.0.1
Port:              https  443/TCP
TargetPort:        6443/TCP
Endpoints:         192.168.65.3:6443
Session Affinity:  None
Events:            <none>
#>

# Expose your service running in the cluster:
kubectl expose deployment "$K8S_APP_NAME" --type=NodePort
<#
You should see something like the following message:
service "mywebapp-dvlp" exposed
#>

# Check the status of your service
kubectl get services --field-selector metadata.name="$K8S_APP_NAME"
<#
You should now see your service in the list:
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
mywebapp-dvlp   NodePort    10.109.86.161   <none>        80:30492/TCP   8s
NOTE: Kubernetes randonly assigns the external port number
#>

# Get pod configuration by a label name as JSON
kubectl get pods --selector run="$K8S_APP_NAME" -o=json 

# Check the status of your pods by label name
kubectl get pods --selector run="$K8S_APP_NAME"

# Get the service configuration as JSON
kubectl get services "$K8S_APP_NAME" -o=json

# Get the service host name
$HOST_NAME = kubectl get svc "$K8S_APP_NAME" -o=jsonpath="{.status.loadBalancer.ingress[*].hostname}"
Write-Verbose "HOST_NAME: $HOST_NAME" -Verbose

# Get the service node port
$NODE_PORT = kubectl get svc "$K8S_APP_NAME" -o=jsonpath="{.spec.ports[?(@.port=="80")].nodePort}"
Write-Verbose "NODE_PORT: $NODE_PORT" -Verbose

# COmbine values to create service URL
$K8S_URI = "http://$HOST_NAME`:$NODE_PORT"
Write-Verbose "K8S_URI: $K8S_URI" -Verbose

# Test the kubernetes service is working:
Start-Process "$K8S_URI"
# The service should launch in a browser

#**********************************************************
# Cleanup you application from local kubernetes instance
#**********************************************************

# Delete your kubernetes deployment
kubectl delete deployment "$K8S_APP_NAME"
<#
You should see something like the following:
deployment.extensions "mywebapp-dvlp" deleted
#>

# Delete your kubernetes service
kubectl delete service "$K8S_APP_NAME"
<#
You should see something like the following:
service "mywebapp-dvlp" deleted
#>

# Verify your deployment was deleted
kubectl get deployments --field-selector metadata.name="$K8S_APP_NAME"
# You should see the message: "No resources found."

# Verify your service was deleted
kubectl get services --field-selector metadata.name="$K8S_APP_NAME"
# You should see the message: "No resources found."

# Verify your service was deleted
kubectl get pods --field-selector metadata.name="$K8S_APP_NAME"
# You should see the message: "No resources found."