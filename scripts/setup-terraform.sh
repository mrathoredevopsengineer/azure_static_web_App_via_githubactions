#!/bin/bash

# Azure Static Web App - Terraform Setup Script
# This script sets up the necessary Azure resources for Terraform state management

set -e

echo "🚀 Azure Static Web App - Terraform Setup"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Prompt for subscription ID
read -p "Enter your Azure Subscription ID: " SUBSCRIPTION_ID

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo -e "${RED}❌ Subscription ID is required${NC}"
    exit 1
fi

# Set the subscription
echo -e "${YELLOW}Setting subscription...${NC}"
az account set --subscription "$SUBSCRIPTION_ID"

# Prompt for configuration
read -p "Enter Resource Group name for Terraform state [terraform-state-rg]: " RG_NAME
RG_NAME=${RG_NAME:-terraform-state-rg}

read -p "Enter Storage Account name for state files [tfstatedev]: " SA_NAME
SA_NAME=${SA_NAME:-tfstatedev}

read -p "Enter Location [eastus]: " LOCATION
LOCATION=${LOCATION:-eastus}

read -p "Enter Container name for state [tfstate]: " CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-tfstate}

echo ""
echo "Configuration:"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo "  Resource Group:  $RG_NAME"
echo "  Storage Account: $SA_NAME"
echo "  Location:        $LOCATION"
echo "  Container:       $CONTAINER_NAME"
echo ""

read -p "Continue with this configuration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# Create resource group
echo -e "${YELLOW}Creating resource group '$RG_NAME'...${NC}"
az group create \
    --name "$RG_NAME" \
    --location "$LOCATION" \
    --tags "CreatedBy=Terraform" "Purpose=TerraformState"

# Create storage account
echo -e "${YELLOW}Creating storage account '$SA_NAME'...${NC}"
az storage account create \
    --name "$SA_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --encryption-services blob \
    --https-only true

# Get storage account key
echo -e "${YELLOW}Retrieving storage account key...${NC}"
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RG_NAME" \
    --account-name "$SA_NAME" \
    --query [0].value \
    --output tsv)

# Create blob container
echo -e "${YELLOW}Creating blob container '$CONTAINER_NAME'...${NC}"
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$SA_NAME" \
    --account-key "$STORAGE_KEY"

echo ""
echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo ""
echo "GitHub Secrets to configure:"
echo "  AZURE_SUBSCRIPTION_ID:      $SUBSCRIPTION_ID"
echo "  TERRAFORM_STATE_RG:         $RG_NAME"
echo "  TERRAFORM_STATE_SA:         $SA_NAME"
echo "  TERRAFORM_STATE_CONTAINER:  $CONTAINER_NAME"
echo ""
echo "Store these values in your GitHub repository secrets:"
echo "  Settings → Secrets and variables → Actions → New repository secret"
echo ""

# Create Azure Service Principal for GitHub Actions
read -p "Create Azure Service Principal for GitHub Actions? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Creating Service Principal...${NC}"
    
    SP_NAME="github-actions-sp"
    SP_JSON=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role Contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID" \
        --json-auth)
    
    echo ""
    echo -e "${GREEN}Service Principal created!${NC}"
    echo ""
    echo "Add this to GitHub Secrets as 'AZURE_CREDENTIALS':"
    echo "$SP_JSON"
    echo ""
fi

echo -e "${GREEN}🎉 Terraform setup is ready!${NC}"
echo "Next steps:"
echo "  1. Add the secrets to your GitHub repository"
echo "  2. Update 'infra/env/dev/dev.tfvars' with your values"
echo "  3. Push your changes to trigger the workflow"
echo ""
