# 🚀 Quick Azure Setup Guide - Step by Step

## Prerequisites
1. Azure account (sign up at https://azure.microsoft.com - free $200 credit for new accounts)
2. Azure CLI installed (or use Azure Portal web interface)

---

## Step 1: Create Azure Resources (Using Azure Portal)

### 1.1 Create Resource Group
1. Go to https://portal.azure.com
2. Click "Create a resource"
3. Search for "Resource group"
4. Click "Create"
5. Name: `animalguardian-rg`
6. Region: `East US` (or closest to you)
7. Click "Review + create" → "Create"

### 1.2 Create PostgreSQL Database
1. In Azure Portal, click "Create a resource"
2. Search for "Azure Database for PostgreSQL"
3. Select "Flexible server"
4. Click "Create"
5. Fill in:
   - **Resource group**: Select `animalguardian-rg`
   - **Server name**: `animalguardian-postgres` (must be unique)
   - **Region**: Same as resource group
   - **PostgreSQL version**: 15
   - **Workload type**: Development
   - **Compute + storage**: Burstable B1ms (cheapest option)
   - **Admin username**: `animalguardian` (or your choice)
   - **Password**: Create a strong password (SAVE THIS!)
   - **Availability zone**: No preference
6. Click "Next: Networking"
7. **Firewall rules**: 
   - Click "Add current client IP address"
   - Click "Allow public access from any Azure service within Azure to this server" (toggle ON)
8. Click "Review + create" → "Create"
9. Wait 5-10 minutes for deployment

### 1.3 Create Database
1. Once PostgreSQL server is created, go to it
2. Click "Databases" in left menu
3. Click "+ Create"
4. Database name: `animalguardian`
5. Click "Create"

---

## Step 2: Create App Service (Web App)

### 2.1 Create App Service Plan
1. In Azure Portal, click "Create a resource"
2. Search for "App Service Plan"
3. Click "Create"
4. Fill in:
   - **Resource group**: `animalguardian-rg`
   - **Name**: `animalguardian-plan`
   - **Operating System**: Linux
   - **Region**: Same as resource group
   - **Pricing tier**: Basic B1 (~$13/month) or Free F1 (for testing)
5. Click "Review + create" → "Create"

### 2.2 Create Web App
1. In Azure Portal, click "Create a resource"
2. Search for "Web App"
3. Click "Create"
4. Fill in:
   - **Resource group**: `animalguardian-rg`
   - **Name**: `animalguardian-backend` (must be globally unique, add numbers if needed)
   - **Publish**: Code
   - **Runtime stack**: Python 3.11
   - **Operating System**: Linux
   - **Region**: Same as resource group
   - **App Service Plan**: Select `animalguardian-plan`
5. Click "Review + create" → "Create"
6. Wait 2-3 minutes for deployment

---

## Step 3: Configure Environment Variables

### 3.1 Get Database Connection String
1. Go to your PostgreSQL server (`animalguardian-postgres`)
2. Click "Connection strings" in left menu
3. Copy the "JDBC" connection string (we'll modify it)
4. It looks like: `jdbc:postgresql://animalguardian-postgres.postgres.database.azure.com:5432/animalguardian?user=animalguardian&password=YOUR_PASSWORD&sslmode=require`
5. Convert to Django format: `postgresql://animalguardian:YOUR_PASSWORD@animalguardian-postgres.postgres.database.azure.com:5432/animalguardian?sslmode=require`

### 3.2 Set App Service Environment Variables
1. Go to your Web App (`animalguardian-backend`)
2. Click "Configuration" in left menu
3. Click "+ New application setting" for each variable:

**Required Variables:**
```
Name: DATABASE_URL
Value: postgresql://animalguardian:YOUR_PASSWORD@animalguardian-postgres.postgres.database.azure.com:5432/animalguardian?sslmode=require
```

```
Name: SECRET_KEY
Value: [Generate using: python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"]
```

```
Name: DEBUG
Value: False
```

```
Name: ALLOWED_HOSTS
Value: animalguardian-backend.azurewebsites.net,*.azurewebsites.net
```

```
Name: DJANGO_SETTINGS_MODULE
Value: animalguardian.settings
```

```
Name: DEFAULT_FROM_EMAIL
Value: mutesijosephine324@gmail.com
```

```
Name: CORS_ALLOWED_ORIGINS
Value: https://animalguards.netlify.app,https://animalguardian-backend.azurewebsites.net,http://localhost:3000,http://localhost:3001
```

```
Name: CSRF_TRUSTED_ORIGINS
Value: https://animalguards.netlify.app,https://animalguardian-backend.azurewebsites.net
```

```
Name: AFRICASTALKING_USERNAME
Value: sandbox
```

```
Name: AFRICASTALKING_API_KEY
Value: atsk_1d0e0702b50384db6c669dce7574ef5971ddf7ebcc411a5a214c39354ad26b363dbc94e2
```

4. Click "Save" at the top
5. Click "Continue" when prompted to restart

---

## Step 4: Configure Deployment

### 4.1 Set Startup Command
1. Go to your Web App → "Configuration"
2. Click "General settings" tab
3. Scroll to "Startup Command"
4. Enter:
   ```bash
   bash startup.sh
   ```
5. Click "Save"

### 4.2 Configure Deployment Center
1. Go to your Web App → "Deployment Center"
2. Select "GitHub" as source
3. Authorize Azure to access GitHub
4. Select:
   - **Organization**: Your GitHub username
   - **Repository**: `AnimalGuardian`
   - **Branch**: `master`
5. Click "Save"
6. Azure will automatically deploy on every push

---

## Step 5: Configure Build Settings

1. Go to your Web App → "Configuration" → "General settings"
2. Set:
   - **Stack**: Python 3.11
   - **Startup Command**: `bash startup.sh`
3. Click "Save"

---

## Step 6: Get Your App URL

1. Go to your Web App
2. Click "Overview" in left menu
3. Copy the "Default domain" (e.g., `https://animalguardian-backend.azurewebsites.net`)

---

## Step 7: Run Migrations

### Option 1: Using Azure Cloud Shell (Easiest)
1. Click the Cloud Shell icon (>) at top of Azure Portal
2. Run:
   ```bash
   az webapp ssh --resource-group animalguardian-rg --name animalguardian-backend
   ```
3. Once connected, run:
   ```bash
   cd /home/site/wwwroot
   python manage.py migrate
   python manage.py create_admin
   ```

### Option 2: Using Kudu Console
1. Go to: `https://animalguardian-backend.scm.azurewebsites.net`
2. Click "Debug Console" → "Bash" or "SSH"
3. Navigate to: `cd site/wwwroot`
4. Run:
   ```bash
   python manage.py migrate
   python manage.py create_admin
   ```

---

## Step 8: Update Frontend Configuration

### Update web-dashboard/.env
```env
REACT_APP_API_URL=https://animalguardian-backend.azurewebsites.net/api
```

### Update netlify.toml
```toml
[build.environment]
REACT_APP_API_URL = "https://animalguardian-backend.azurewebsites.net/api"
```

---

## Step 9: Test Your Deployment

1. Health check: `https://animalguardian-backend.azurewebsites.net/api/dashboard/health/`
2. Test login with your credentials
3. Check logs: Web App → "Log stream"

---

## Troubleshooting

### View Logs
1. Go to Web App → "Log stream" (real-time logs)
2. Or "Logs" → "Application Logging" (enable if needed)

### Common Issues
- **503 Error**: Check startup command and logs
- **Database Connection Error**: Verify DATABASE_URL and firewall rules
- **500 Error**: Check application logs for Python errors

---

## Cost Estimate
- **App Service Plan (B1)**: ~$13/month
- **PostgreSQL (B1ms)**: ~$12/month
- **Total**: ~$25/month

**Free Tier Available**: Azure offers free tier for 12 months for new accounts!

---

## Next Steps
1. Test all endpoints
2. Update frontend to use Azure URL
3. Set up custom domain (optional)
4. Monitor costs in Azure Portal

