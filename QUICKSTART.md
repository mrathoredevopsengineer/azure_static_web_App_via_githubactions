# ⚡ Quick Start Checklist

## 🚀 Get Your Azure Static Web App Live in 5 Steps

### Step 1: Run Setup Script ✓
```bash
# Windows
.\scripts\setup-terraform.bat

# Linux/macOS
chmod +x scripts/setup-terraform.sh
./scripts/setup-terraform.sh
```

**What it does:**
- Creates Azure Resource Group for Terraform state
- Creates Storage Account for remote state
- Creates Blob Container
- Generates Azure credentials for GitHub

---

### Step 2: Configure GitHub Secrets ✓

Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

Add these secrets (from Step 1 output):

```
AZURE_CREDENTIALS                  = [JSON from script]
AZURE_SUBSCRIPTION_ID              = [Your subscription ID]
TERRAFORM_STATE_RG                 = terraform-state-rg
TERRAFORM_STATE_SA                 = tfstatedev
TERRAFORM_STATE_CONTAINER          = tfstate
```

---

### Step 3: Update Variables ✓

Edit: `infra/env/dev/dev.tfvars`

```hcl
subscription_id = "YOUR_SUBSCRIPTION_ID_HERE"  # ← Change this
environment     = "dev"
project_name    = "myapp"                      # ← Change this
location        = "eastus"
sku_tier        = "Standard"
```

---

### Step 4: Push to GitHub ✓

```bash
git add .
git commit -m "Add Terraform and GitHub Actions"
git push origin main
```

---

### Step 5: Monitor Deployment ✓

Go to: **GitHub Repo → Actions**

Watch the workflow run:
1. ✅ Terraform Plan
2. ✅ Terraform Apply
3. ✅ Check outputs for your Static Web App URL

---

## 📊 Expected Output After Deployment

After successful deployment, you'll see:
- **Resource Group**: `myapp-dev-rg`
- **Static Web App**: `myapp-dev-swa`
- **URL**: `https://random-hash.azurestaticapps.net`
- **API Token**: Shown in outputs (for app deployment)

---

## 🔄 Next: Deploy Your Application

```bash
# Get the SWA API token
az staticwebapp secrets list --name "myapp-dev-swa" -g "myapp-dev-rg"

# Add as GitHub secret: AZURE_STATIC_WEB_APPS_API_TOKEN
```

Then the `deploy-swa.yml` workflow will automatically deploy your app!

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Script fails | Ensure Azure CLI is installed: `az --version` |
| Secrets not found | Check GitHub Secrets spelling matches exactly |
| Terraform fails | Check subscription ID is correct in tfvars |
| SWA not accessible | Wait 5 mins for DNS, check URL in Terraform outputs |

---

## 📞 Need Help?

1. Check **GitHub Actions** logs for detailed errors
2. Review **SETUP_GUIDE.md** for detailed instructions
3. Check **README.md** for troubleshooting section

---

## ✅ You're Ready!

Your Azure Static Web App is now deployed with:
- ✅ Infrastructure as Code (Terraform)
- ✅ Automated CI/CD (GitHub Actions)
- ✅ Remote State Management
- ✅ Multi-environment Ready

**Happy Deploying! 🎉**
