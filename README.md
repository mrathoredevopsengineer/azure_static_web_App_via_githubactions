# Azure Static Web App via Terraform & GitHub Actions

Complete setup for deploying Azure Static Web App using Terraform Infrastructure as Code with GitHub Actions CI/CD.

## 📋 Prerequisites

- Azure Subscription
- GitHub Repository
- Azure CLI installed locally (optional, for setup)
- Terraform installed locally (optional, for local development)

## 🏗️ Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform-deploy.yml      # Terraform IaC deployment
│       └── deploy-swa.yml            # Application deployment
├── infra/
│   ├── main.tf                       # Main Terraform configuration
│   ├── variables.tf                  # Variable definitions
│   ├── output.tf                     # Output values
│   ├── provider.tf                   # Azure provider config
│   ├── locals.tf                     # Local variables
│   ├── data.tf                       # Data sources
│   └── env/
│       └── dev/
│           ├── dev.tfvars            # Dev environment variables
│           └── dev.backend.tf        # Dev backend config
└── app/                              # Your application code
    ├── src/
    ├── build/                        # Build output
    ├── package.json
    └── ...
```

## 🔑 GitHub Secrets Setup

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### Azure Authentication
- `AZURE_CREDENTIALS`: Full Azure credentials JSON (for `azure/login@v1`)
  ```bash
  az ad sp create-for-rbac --name "github-actions-sp" --role "Contributor" --scopes /subscriptions/{subscription-id} --json
  ```

### Terraform State Management
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `TERRAFORM_STATE_RG`: Resource group for Terraform state (e.g., `terraform-state-rg`)
- `TERRAFORM_STATE_SA`: Storage account name for state files (e.g., `tfstatedev`)
- `TERRAFORM_STATE_CONTAINER`: Container name in storage account (e.g., `tfstate`)

### Static Web App Deployment
- `AZURE_STATIC_WEB_APPS_API_TOKEN`: Retrieved after SWA creation
  - Get it from: Azure Portal → Your SWA → Manage deployment token

## 🚀 Quick Start

### 1. Setup Terraform State Storage (One-time setup)

```bash
# Create resource group
az group create --name terraform-state-rg --location eastus

# Create storage account
az storage account create --resource-group terraform-state-rg \
  --name tfstatedev --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name tfstate \
  --account-name tfstatedev --account-key $(az storage account keys list -g terraform-state-rg -n tfstatedev --query [0].value -o tsv)
```

### 2. Update Configuration Files

Update the following files with your values:

**infra/env/dev/dev.tfvars:**
```hcl
subscription_id = "YOUR_SUBSCRIPTION_ID"
environment     = "dev"
project_name    = "myapp"          # Change this
location        = "eastus"
sku_tier        = "Standard"       # or "Free"
sku_size        = "Standard"
custom_domain   = null             # Add custom domain if needed
```

### 3. Commit and Push

```bash
git add .
git commit -m "Add Terraform and GitHub Actions workflow"
git push origin main
```

The GitHub Actions workflow will automatically:
1. ✅ Validate Terraform code
2. 📋 Generate a plan
3. 🚀 Apply the configuration
4. 📊 Output the Static Web App details

### 4. Retrieve SWA API Token

After the first Terraform deployment completes:

```bash
# Get the API token from Azure Portal
az staticwebapp secrets list --name "myapp-dev-swa" --resource-group "myapp-dev-rg"
```

Add the token as `AZURE_STATIC_WEB_APPS_API_TOKEN` secret in GitHub.

## 📝 Terraform Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_id` | string | - | Azure Subscription ID |
| `environment` | string | - | Environment (dev/staging/prod) |
| `project_name` | string | - | Project name for resources |
| `location` | string | `eastus` | Azure region |
| `sku_tier` | string | `Standard` | SKU tier (Free/Standard) |
| `sku_size` | string | `Standard` | SKU size |
| `custom_domain` | string | `null` | Custom domain name (optional) |
| `validation_type` | string | `cname` | Domain validation type |

## 📤 Terraform Outputs

The deployment provides these outputs:

- `resource_group_name`: Name of the resource group
- `static_web_app_name`: Name of the Static Web App
- `static_web_app_id`: Azure resource ID of the SWA
- `default_host_name`: Default hostname of the SWA
- `api_key`: API key for the SWA (sensitive)

## 🔄 Deployment Workflows

### Terraform Deployment (Infrastructure)
- **Triggers**: Push to main/develop, changes to `infra/`, manual dispatch
- **Environments**: Auto-detected from branch or manual selection
- **Process**: Plan → Apply

### Application Deployment
- **Triggers**: Push to main/develop, changes to `app/src/`, manual dispatch
- **Process**: Build → Deploy to SWA

## 🛠️ Local Terraform Commands

```bash
# Initialize Terraform
cd infra
terraform init -backend-config="subscription_id=YOUR_SUB_ID" \
  -backend-config="resource_group_name=terraform-state-rg" \
  -backend-config="storage_account_name=tfstatedev" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/terraform.tfstate"

# Plan deployment
terraform plan -var-file="env/dev/dev.tfvars"

# Apply deployment
terraform apply -var-file="env/dev/dev.tfvars"

# Destroy resources (if needed)
terraform destroy -var-file="env/dev/dev.tfvars"

# Get outputs
terraform output
```

## 🔐 Security Best Practices

1. ✅ Store Terraform state in remote backend (Azure Storage)
2. ✅ Use service principals with minimal required permissions
3. ✅ Keep sensitive outputs (API keys) as secrets
4. ✅ Review Terraform plans before applying
5. ✅ Use GitHub environments for approval gates
6. ✅ Enable audit logging for resource changes
7. ✅ Rotate service principal credentials regularly

## 📊 Monitoring Deployment

Monitor your deployments:

1. **GitHub Actions**: View workflow runs in Actions tab
2. **Azure Portal**: Check Static Web App resource
3. **Azure CLI**:
   ```bash
   az staticwebapp show --name "myapp-dev-swa" --resource-group "myapp-dev-rg"
   ```

## 🐛 Troubleshooting

### "Backend init failed"
- Verify storage account and container exist
- Check storage account access key
- Ensure resource group name is correct

### "Terraform Apply failed"
- Check Azure credentials in secrets
- Verify subscription ID and location are valid
- Review Terraform plan output for details

### "Application deployment failed"
- Ensure AZURE_STATIC_WEB_APPS_API_TOKEN is set correctly
- Verify app build output location matches workflow config
- Check SWA deployment token hasn't expired

## 📚 Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Static Web Apps](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform State Management](https://www.terraform.io/docs/backends/)

## 📞 Support

For issues or questions:
1. Check GitHub Actions logs
2. Review Terraform output messages
3. Verify all secrets are configured correctly
4. Check Azure Portal for resource creation status

---

**Last Updated:** June 2026
