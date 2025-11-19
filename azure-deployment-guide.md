# Azure Deployment Guide for AnimalGuardian

## Overview
This guide will help you deploy AnimalGuardian to Azure with:
- **Azure App Service** - For Django backend
- **Azure Database for PostgreSQL** - For database
- **Azure Static Web Apps** or **Azure App Service** - For React frontend

## Prerequisites
1. Azure account (free tier available)
2. Azure CLI installed
3. GitHub repository connected

---

## Step 1: Create Azure Database for PostgreSQL

### Option A: Using Azure Portal
1. Go to [Azure Portal](https://portal.azure.com)
2. Click **"Create a resource"**
3. Search for **"Azure Database for PostgreSQL"**
4. Select **"Flexible Server"** (recommended)
5. Fill in the details:
   - **Subscription**: Your subscription
   - **Resource Group**: Create new or use existing
   - **Server name**: `animalguardian-postgres` (must be globally unique)
   - **Region**: Choose closest to your users
   - **PostgreSQL version**: 15 (or latest)
   - **Compute + storage**: Basic tier (B1ms) for development
   - **Admin username**: `animalguardian_admin`
   - **Password**: Create a strong password
6. Click **"Review + create"** then **"Create"**

### Option B: Using Azure CLI
```bash
# Login to Azure
az login

# Create resource group
az group create --name animalguardian-rg --location eastus

# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --location eastus \
  --admin-user animalguardian_admin \
  --admin-password <your-strong-password> \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 15 \
  --storage-size 32 \
  --public-access 0.0.0.0
```

### Get Connection String
After creation, get the connection string:
```bash
az postgres flexible-server show-connection-string \
  --server-name animalguardian-postgres \
  --admin-user animalguardian_admin \
  --admin-password <your-password> \
  --database-name postgres
```

The connection string will look like:
```
postgresql://animalguardian_admin:<password>@animalguardian-postgres.postgres.database.azure.com:5432/postgres?sslmode=require
```

---

## Step 2: Deploy Django Backend to Azure App Service

### Option A: Using Azure Portal
1. Go to Azure Portal → **"Create a resource"**
2. Search for **"Web App"**
3. Fill in details:
   - **Name**: `animalguardian-backend` (must be globally unique)
   - **Runtime stack**: Python 3.11
   - **Operating System**: Linux
   - **Region**: Same as database
   - **App Service Plan**: Create new (Basic B1 for development)
4. Click **"Review + create"** then **"Create"**

### Option B: Using Azure CLI
```bash
# Create App Service Plan
az appservice plan create \
  --name animalguardian-plan \
  --resource-group animalguardian-rg \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group animalguardian-rg \
  --plan animalguardian-plan \
  --name animalguardian-backend \
  --runtime "PYTHON:3.11"
```

### Configure Environment Variables
```bash
az webapp config appsettings set \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --settings \
    DATABASE_URL="postgresql://animalguardian_admin:<password>@animalguardian-postgres.postgres.database.azure.com:5432/animalguardian?sslmode=require" \
    SECRET_KEY="<generate-a-secret-key>" \
    DEBUG="False" \
    ALLOWED_HOSTS="animalguardian-backend.azurewebsites.net,*.azurewebsites.net" \
    DJANGO_SETTINGS_MODULE="animalguardian.settings" \
    DEFAULT_FROM_EMAIL="mutesijosephine324@gmail.com" \
    CORS_ALLOWED_ORIGINS="https://your-frontend-url.azurestaticapps.net,https://animalguards.netlify.app" \
    CSRF_TRUSTED_ORIGINS="https://your-frontend-url.azurestaticapps.net,https://animalguards.netlify.app"
```

### Deploy from GitHub
1. Go to your Web App in Azure Portal
2. Go to **"Deployment Center"**
3. Select **"GitHub"** as source
4. Authorize Azure to access your GitHub
5. Select repository: `josephine324/AnimalGuardian`
6. Branch: `master`
7. Build provider: **"GitHub Actions"** (recommended)
8. Click **"Save"**

Azure will automatically create a GitHub Actions workflow file.

---

## Step 3: Configure Database Firewall

Allow Azure App Service to access PostgreSQL:

```bash
# Get your App Service outbound IPs
az webapp show \
  --resource-group animalguardian-rg \
  --name animalguardian-backend \
  --query outboundIpAddresses \
  --output tsv

# Add firewall rule (replace <ip-address> with the IP from above)
az postgres flexible-server firewall-rule create \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

Or allow all Azure services:
- Go to Azure Portal → Your PostgreSQL server → **"Networking"**
- Enable **"Allow public access from any Azure service within Azure to this server"**

---

## Step 4: Run Migrations

After deployment, run migrations:

```bash
# Using Azure CLI
az webapp ssh --resource-group animalguardian-rg --name animalguardian-backend

# In the SSH session:
cd /home/site/wwwroot
python manage.py migrate
python manage.py create_admin
```

Or use Azure Portal:
1. Go to your Web App → **"SSH"** or **"Console"**
2. Run the commands above

---

## Step 5: Deploy Frontend to Azure Static Web Apps

1. Go to Azure Portal → **"Create a resource"**
2. Search for **"Static Web App"**
3. Fill in details:
   - **Name**: `animalguardian-frontend`
   - **Deployment details**: GitHub
   - **Repository**: `josephine324/AnimalGuardian`
   - **Branch**: `master`
   - **Build presets**: React
   - **App location**: `web-dashboard`
   - **Api location**: (leave empty)
   - **Output location**: `build`
4. Click **"Review + create"** then **"Create"**

### Update Frontend Environment Variables
In Azure Static Web Apps:
1. Go to **"Configuration"** → **"Application settings"**
2. Add:
   - `REACT_APP_API_URL`: `https://animalguardian-backend.azurewebsites.net/api`

---

## Alternative: Use Render (Easier Alternative)

If Azure setup is complex, consider **Render** which is simpler:

### Render Setup
1. Go to [render.com](https://render.com)
2. Create PostgreSQL database
3. Deploy Django backend from GitHub
4. Set environment variables
5. Deploy frontend to Netlify (already configured)

Render provides:
- Free PostgreSQL database
- Automatic deployments from GitHub
- Simple configuration
- Better for Django apps

---

## Cost Comparison

### Azure (Estimated Monthly)
- PostgreSQL Flexible Server (Basic): ~$12-15/month
- App Service (Basic B1): ~$13/month
- Static Web Apps: Free tier available
- **Total**: ~$25-30/month

### Render (Estimated Monthly)
- PostgreSQL: Free tier available
- Web Service: Free tier available (with limitations)
- **Total**: Free tier or ~$7-25/month

### Railway (Current)
- PostgreSQL: ~$5/month
- Web Service: ~$5/month
- **Total**: ~$10/month

---

## Migration Steps from Railway to Azure

1. **Export data from Railway PostgreSQL**:
   ```bash
   pg_dump -h <railway-host> -U <user> -d <database> > backup.sql
   ```

2. **Import to Azure PostgreSQL**:
   ```bash
   psql -h animalguardian-postgres.postgres.database.azure.com \
        -U animalguardian_admin \
        -d animalguardian \
        -f backup.sql
   ```

3. **Update environment variables** in Azure App Service

4. **Deploy backend** to Azure App Service

5. **Update frontend** API URL to point to Azure

6. **Test and verify** everything works

---

## Quick Start Commands

```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "<subscription-id>"

# Create resource group
az group create --name animalguardian-rg --location eastus

# Create PostgreSQL
az postgres flexible-server create \
  --resource-group animalguardian-rg \
  --name animalguardian-postgres \
  --location eastus \
  --admin-user admin \
  --admin-password <password> \
  --sku-name Standard_B1ms \
  --public-access 0.0.0.0

# Create App Service
az appservice plan create \
  --name animalguardian-plan \
  --resource-group animalguardian-rg \
  --sku B1 \
  --is-linux

az webapp create \
  --resource-group animalguardian-rg \
  --plan animalguardian-plan \
  --name animalguardian-backend \
  --runtime "PYTHON:3.11"
```

---

## Need Help?

If you need assistance with Azure deployment, I can:
1. Create Azure-specific configuration files
2. Set up GitHub Actions for automatic deployment
3. Help migrate your database from Railway to Azure
4. Configure all environment variables

Would you like me to proceed with creating the Azure deployment files?

