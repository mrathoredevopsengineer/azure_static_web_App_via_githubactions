# Setup Guide for Azure Static Web App with Terraform

Complete step-by-step guide to set up and deploy your Azure Static Web App using Terraform and GitHub Actions.

## 📋 Prerequisites

- Azure Subscription (with Contributor access)
- GitHub Account with a repository
- Azure CLI installed on your machine
- Git installed on your machine

## 🎯 Step-by-Step Setup

### Step 1: Clone and Prepare Repository

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Create initial directory structure if not already done
mkdir -p infra/env/dev
mkdir -p .github/workflows
mkdir -p scripts
```

### Step 2: Run the Setup Script

Use the provided setup script to create the backend infrastructure:

**On Linux/macOS:**
```bash
chmod +x scripts/setup-terraform.sh
./scripts/setup-terraform.sh
```

**On Windows (PowerShell):**
```powershell
.\scripts\setup-terraform.bat
```

**Or manually (if script doesn't work):**
```bash
# 1. Create Resource Group
az group create --name terraform-state-rg --location eastus

# 2. Create Storage Account
az storage account create \
  --resource-group terraform-state-rg \
  --name tfstatedev \
  --sku Standard_LRS \
  --kind StorageV2 \
  --encryption-services blob

# 3. Create Blob Container
STORAGE_KEY=$(az storage account keys list -g terraform-state-rg -n tfstatedev --query [0].value -o tsv)
az storage container create -n tfstate --account-name tfstatedev --account-key $STORAGE_KEY

# 4. Create Service Principal
az ad sp create-for-rbac --name "github-actions-sp" --role "Contributor" --scopes /subscriptions/{subscription-id} --json-auth
```

### Step 3: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Value | Where to get |
|---|---|---|
| `AZURE_CREDENTIALS` | JSON output from `az ad sp create-for-rbac` | From Step 2 |
| `AZURE_SUBSCRIPTION_ID` | Your subscription ID | Azure Portal or `az account show --query id -o tsv` |
| `TERRAFORM_STATE_RG` | `terraform-state-rg` | Created in Step 2 |
| `TERRAFORM_STATE_SA` | `tfstatedev` | Created in Step 2 |
| `TERRAFORM_STATE_CONTAINER` | `tfstate` | Created in Step 2 |

### Step 4: Update Terraform Variables

Edit `infra/env/dev/dev.tfvars`:

```hcl
subscription_id = "YOUR_SUBSCRIPTION_ID"      # Replace with your subscription ID
environment     = "dev"
project_name    = "myapp"                     # Replace with your project name
location        = "eastus"                    # Change if needed
sku_tier        = "Standard"                  # "Free" for testing
sku_size        = "Standard"
custom_domain   = null                        # Add domain if you have one
```

### Step 5: Commit and Push

```bash
git add .
git commit -m "Add Terraform and GitHub Actions for Static Web App"
git push origin main
```

The workflow should automatically trigger. Check the **Actions** tab to monitor the deployment.

## 🔄 Workflow Details

### Terraform Deployment Workflow (`terraform-deploy.yml`)

**Triggers:**
- Push to `main` or `develop` branch with changes to `infra/`
- Manual trigger via workflow_dispatch

**Jobs:**
1. **Determine Environment** - Auto-detects environment based on branch
2. **Terraform Plan** - Validates and plans changes
3. **Terraform Apply** - Applies changes (only on push/dispatch, not on PR)

**Outputs:**
- Resource group name
- Static Web App name and ID
- Default hostname
- API key (sensitive)

### Application Deployment Workflow (`deploy-swa.yml`)

**Triggers:**
- Push to `main` or `develop` with changes to `app/src/`
- Manual trigger

**Jobs:**
1. Build application
2. Deploy to Static Web App using SWA API token

## 🔑 Getting SWA API Token

After Terraform creates the Static Web App:

```bash
# Method 1: Using Azure CLI
az staticwebapp secrets list \
  --name "myapp-dev-swa" \
  --resource-group "myapp-dev-rg"

# Method 2: Using Azure Portal
# Navigate to: Resource → Settings → Manage deployment token
```

Add the token to GitHub Secrets as `AZURE_STATIC_WEB_APPS_API_TOKEN`

## 📁 File Structure Explained

```
.
├── .github/workflows/
│   ├── terraform-deploy.yml      # Infrastructure deployment
│   └── deploy-swa.yml            # Application deployment
├── infra/
│   ├── main.tf                   # Static Web App resource
│   ├── variables.tf              # Variable definitions
│   ├── output.tf                 # Output values
│   ├── provider.tf               # Azure provider
│   ├── locals.tf                 # Local variables & tags
│   ├── data.tf                   # Data sources
│   └── env/dev/
│       ├── dev.tfvars            # Dev environment values
│       └── dev.backend.tf        # Remote state config
├── scripts/
│   ├── setup-terraform.sh        # Linux/macOS setup
│   └── setup-terraform.bat       # Windows setup
├── app/                          # Your web app code
│   └── build/                    # Build output
└── README.md                     # Main documentation
```

## 🚀 Deploying Your Application

### Option 1: Deploy via GitHub Actions

1. Build your app in the `app/` directory
2. Push to `main` branch with changes in `app/src/`
3. Workflow automatically builds and deploys

### Option 2: Manual Deploy via Azure CLI

```bash
# First, get the SWA API token
TOKEN=$(az staticwebapp secrets list --name "myapp-dev-swa" -g "myapp-dev-rg" --query properties.apiKey -o tsv)

# Deploy your app
swa deploy ./app/build --deployment-token=$TOKEN
```

### Option 3: Deploy via VS Code Extension

1. Install "Azure Static Web Apps" extension
2. Sign in to Azure
3. Select your Static Web App
4. Deploy from VS Code

## 🧪 Testing Terraform Locally

```bash
cd infra

# Initialize
terraform init \
  -backend-config="subscription_id=YOUR_SUB_ID" \
  -backend-config="resource_group_name=terraform-state-rg" \
  -backend-config="storage_account_name=tfstatedev" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/terraform.tfstate"

# Plan
terraform plan -var-file="env/dev/dev.tfvars"

# Apply
terraform apply -var-file="env/dev/dev.tfvars"

# View outputs
terraform output
```

## 🔧 Customization

### Adding Custom Domain

1. Update `dev.tfvars`:
   ```hcl
   custom_domain = "myapp.example.com"
   ```

2. Commit and push - Terraform will create the custom domain resource

3. Update DNS records as instructed by Azure

### Changing SKU

Update `dev.tfvars`:
```hcl
sku_tier = "Free"    # for testing
# or
sku_tier = "Standard"  # for production
```

### Adding Staging Environment

1. Copy `infra/env/dev/` to `infra/env/staging/`
2. Update `staging/staging.tfvars`
3. Create new branch `develop`
4. Push to trigger workflow for staging

## 🐛 Troubleshooting

### Backend Initialization Fails

**Error:** `"Unable to access storage account"`

**Solution:**
- Verify storage account exists: `az storage account show -g terraform-state-rg -n tfstatedev`
- Check storage key: `az storage account keys list -g terraform-state-rg -n tfstatedev`
- Verify container exists: `az storage container exists -n tfstate --account-name tfstatedev`

### Terraform Plan Shows Many Changes After First Run

This is normal if:
- It's the first time running
- You just modified variables
- Use `terraform refresh` to update state

### GitHub Actions Workflow Fails

1. Check **Actions** tab for detailed error logs
2. Verify all secrets are set correctly
3. Check Azure resource quotas
4. Verify service principal has correct permissions

### Static Web App Not Accessible

1. Wait a few minutes for DNS propagation
2. Check default hostname: `terraform output default_host_name`
3. Verify app deployed successfully: Check workflow logs
4. Check SWA in Azure Portal for deployment status

## 📞 Getting Help

- Check GitHub Actions logs
- Review Azure Portal resource creation
- Run `terraform validate` to check syntax
- Run `terraform plan` to see what would change

## ✅ Next Steps

1. ✅ Run setup script
2. ✅ Configure GitHub secrets
3. ✅ Update tfvars
4. ✅ Push to GitHub
5. ✅ Monitor Actions workflow
6. ✅ Access your Static Web App
7. ✅ Add custom domain (optional)
8. ✅ Set up environment protections (optional)

---

**Questions?** See the main [README.md](README.md) for more information.
