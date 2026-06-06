@echo off
REM Azure Static Web App - Terraform Setup Script (Windows)
REM This script sets up the necessary Azure resources for Terraform state management

setlocal enabledelayedexpansion

echo.
echo 🚀 Azure Static Web App - Terraform Setup
echo ==========================================
echo.

:get_subscription
set /p SUBSCRIPTION_ID="Enter your Azure Subscription ID: "

if "!SUBSCRIPTION_ID!"=="" (
    echo ❌ Subscription ID is required
    exit /b 1
)

REM Set the subscription
echo Setting subscription...
call az account set --subscription "!SUBSCRIPTION_ID!"
if errorlevel 1 exit /b 1

REM Prompt for configuration
set /p RG_NAME="Enter Resource Group name for Terraform state [terraform-state-rg]: "
if "!RG_NAME!"=="" set RG_NAME=terraform-state-rg

set /p SA_NAME="Enter Storage Account name for state files [tfstatedev]: "
if "!SA_NAME!"=="" set SA_NAME=tfstatedev

set /p LOCATION="Enter Location [eastus]: "
if "!LOCATION!"=="" set LOCATION=eastus

set /p CONTAINER_NAME="Enter Container name for state [tfstate]: "
if "!CONTAINER_NAME!"=="" set CONTAINER_NAME=tfstate

echo.
echo Configuration:
echo   Subscription ID: !SUBSCRIPTION_ID!
echo   Resource Group:  !RG_NAME!
echo   Storage Account: !SA_NAME!
echo   Location:        !LOCATION!
echo   Container:       !CONTAINER_NAME!
echo.

set /p CONFIRM="Continue with this configuration? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo Cancelled.
    exit /b 0
)

REM Create resource group
echo Creating resource group '!RG_NAME!'...
call az group create ^
    --name "!RG_NAME!" ^
    --location "!LOCATION!" ^
    --tags "CreatedBy=Terraform" "Purpose=TerraformState"
if errorlevel 1 exit /b 1

REM Create storage account
echo Creating storage account '!SA_NAME!'...
call az storage account create ^
    --name "!SA_NAME!" ^
    --resource-group "!RG_NAME!" ^
    --location "!LOCATION!" ^
    --sku Standard_LRS ^
    --kind StorageV2 ^
    --encryption-services blob ^
    --https-only true
if errorlevel 1 exit /b 1

REM Get storage account key
echo Retrieving storage account key...
for /f "delims=" %%i in ('az storage account keys list --resource-group "!RG_NAME!" --account-name "!SA_NAME!" --query [0].value --output tsv') do set STORAGE_KEY=%%i

REM Create blob container
echo Creating blob container '!CONTAINER_NAME!'...
call az storage container create ^
    --name "!CONTAINER_NAME!" ^
    --account-name "!SA_NAME!" ^
    --account-key "!STORAGE_KEY!"
if errorlevel 1 exit /b 1

echo.
echo ✅ Setup completed successfully!
echo.
echo GitHub Secrets to configure:
echo   AZURE_SUBSCRIPTION_ID:      !SUBSCRIPTION_ID!
echo   TERRAFORM_STATE_RG:         !RG_NAME!
echo   TERRAFORM_STATE_SA:         !SA_NAME!
echo   TERRAFORM_STATE_CONTAINER:  !CONTAINER_NAME!
echo.
echo Store these values in your GitHub repository secrets:
echo   Settings → Secrets and variables → Actions → New repository secret
echo.

set /p CREATE_SP="Create Azure Service Principal for GitHub Actions? (y/n): "
if /i "!CREATE_SP!"=="y" (
    echo Creating Service Principal...
    
    set SP_NAME=github-actions-sp
    
    echo.
    echo 📋 Running command to create Service Principal...
    call az ad sp create-for-rbac ^
        --name "!SP_NAME!" ^
        --role Contributor ^
        --scopes "/subscriptions/!SUBSCRIPTION_ID!" ^
        --json-auth
    
    echo.
    echo ✅ Service Principal created!
    echo.
    echo Add the JSON output above to GitHub Secrets as 'AZURE_CREDENTIALS'
    echo.
)

echo.
echo 🎉 Terraform setup is ready!
echo Next steps:
echo   1. Add the secrets to your GitHub repository
echo   2. Update 'infra\env\dev\dev.tfvars' with your values
echo   3. Push your changes to trigger the workflow
echo.

endlocal
