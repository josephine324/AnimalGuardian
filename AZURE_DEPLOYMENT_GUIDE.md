# 🚀 Azure Deployment Guide for AnimalGuardian Backend

This guide will help you deploy your Django backend to Azure App Service with Azure Database for PostgreSQL.

## Prerequisites

1. **Azure Account**: Sign up at [azure.microsoft.com](https://azure.microsoft.com)
2. **Azure CLI**: Install from [docs.microsoft.com/cli/azure](https://docs.microsoft.com/cli/azure/install-azure-cli)
3. **GitHub Repository**: Your code should be pushed to GitHub

---

## Step 1: Create Azure Resources

### 1.1 Create Resource Group

```bash
az group create --name animalguardian-rg --location eastus
```

### 1.2 Create PostgreSQL Database

```bash
# Create PostgreSQL Flexible Server
az postgres flexible-server create \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --location eastus \
  --admin-user animalguardian \
  --admin-password "YourSecurePassword123!" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 15 \
  --storage-size 32 \
  --public-access 0.0.0.0
```

**Note:** Replace `YourSecurePassword123!` with a strong password. Save this password!

### 1.3 Create Database

```bash
az postgres flexible-server db create \
  --resource-group animalguardian-rg \
  --server-name animalguardian-postgres \
  --database-name animalguardian
```

### 1.4 Configure Firewall (Allow Azure Services)

```bash
# Allow Azure services to access
az postgres flexible-server firewall-rule create \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

---

## Step 2: Create Azure App Service

### 2.1 Create App Service Plan

```bash
az appservice plan create \
  --name animalguardian-plan \
  --resource-group animalguardian-rg \
  --location eastus \
  --sku B1 \
  --is-linux
```

### 2.2 Create Web App

```bash
az webapp create \
  --resource-group animalguardian-rg \
  --plan animalguardian-plan \
  --name animalguardian-backend \
  --runtime "PYTHON:3.11"
```

---

## Step 3: Configure Environment Variables

### 3.1 Get Database Connection String

```bash
# Get connection details
az postgres flexible-server show \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --query "{FQDN:fullyQualifiedDomainName,AdminUser:administratorLogin}" \
  --output table
```

### 3.2 Set App Service Environment Variables

```bash
# Set environment variables
az webapp config appsettings set \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --settings \
    DATABASE_URL="postgresql://animalguardian:YourSecurePassword123!@animalguardian-postgres.postgres.database.azure.com:5432/animalguardian?sslmode=require" \
    SECRET_KEY="$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" \
    DEBUG="False" \
    ALLOWED_HOSTS="animalguardian-backend.azurewebsites.net,*.azurewebsites.net" \
    DJANGO_SETTINGS_MODULE="animalguardian.settings" \
    DEFAULT_FROM_EMAIL="mutesijosephine324@gmail.com" \
    CORS_ALLOWED_ORIGINS="https://animalguards.netlify.app,https://animalguardian-backend.azurewebsites.net,http://localhost:3000,http://localhost:3001" \
    CSRF_TRUSTED_ORIGINS="https://animalguards.netlify.app,https://animalguardian-backend.azurewebsites.net" \
    AFRICASTALKING_USERNAME="sandbox" \
    AFRICASTALKING_API_KEY="atsk_1d0e0702b50384db6c669dce7574ef5971ddf7ebcc411a5a214c39354ad26b363dbc94e2"
```

**Important:** Replace `YourSecurePassword123!` with your actual database password.

---

## Step 4: Configure Deployment

### 4.1 Enable Continuous Deployment from GitHub

```bash
az webapp deployment source config \
  --name animalguardian-backend \
  --resource-group animalguardian-rg \
  --repo-url https://github.com/josephine324/AnimalGuardian \
  --branch master \
  --manual-integration
```

### 4.2 Configure Startup Command

```bash
az webapp config set \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --startup-file "gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 600 animalguardian.wsgi:application"
```

---

## Step 5: Create Deployment Files

### 5.1 Create `.deployment` file (in backend directory)

```
[config]
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

### 5.2 Create `startup.sh` for Azure

```bash
#!/bin/bash
# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start gunicorn
exec gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 600 animalguardian.wsgi:application
```

---

## Step 6: Update Django Settings for Azure

The settings.py already supports DATABASE_URL, so it should work. But we may need to add Azure-specific configurations.

---

## Step 7: Deploy and Test

### 7.1 Deploy

Push to GitHub and Azure will automatically deploy, or manually deploy:

```bash
az webapp up \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --runtime "PYTHON:3.11"
```

### 7.2 Get Your App URL

```bash
az webapp show \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --query defaultHostName \
  --output tsv
```

Your backend will be available at: `https://animalguardian-backend.azurewebsites.net`

---

## Step 8: Run Migrations

### Option 1: Using Azure CLI

```bash
az webapp ssh --resource-group animalguardian-rg --name animalguardian-backend
# Then in the SSH session:
python manage.py migrate
python manage.py create_admin
```

### Option 2: Using Kudu Console

1. Go to: `https://animalguardian-backend.scm.azurewebsites.net`
2. Click "Debug Console" → "SSH"
3. Run:
   ```bash
   cd /home/site/wwwroot
   python manage.py migrate
   python manage.py create_admin
   ```

---

## Step 9: Update Frontend Configuration

Update your frontend `.env` and `netlify.toml`:

```env
REACT_APP_API_URL=https://animalguardian-backend.azurewebsites.net/api
```

---

## Cost Estimate

- **App Service Plan (B1)**: ~$13/month
- **PostgreSQL Flexible Server (Burstable B1ms)**: ~$12/month
- **Total**: ~$25/month

Azure offers a free tier for 12 months for new accounts.

---

## Troubleshooting

### View Logs

```bash
az webapp log tail \
  --resource-group animalguardian-rg \
  --name animalguardian-backend
```

### Check App Status

```bash
az webapp show \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --query state
```

---

## Next Steps

1. Test the health endpoint: `https://animalguardian-backend.azurewebsites.net/api/dashboard/health/`
2. Test login with your credentials
3. Update frontend to use new Azure URL
4. Monitor costs in Azure Portal

