#!/bin/bash
# Azure Setup Script for AnimalGuardian
# This script helps set up Azure resources for deployment

set -e

echo "=========================================="
echo "Azure Setup for AnimalGuardian"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed."
    echo "Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo "✅ Azure CLI found"
echo ""

# Login to Azure
echo "Please login to Azure..."
az login

# Set variables
read -p "Enter resource group name (default: animalguardian-rg): " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-animalguardian-rg}

read -p "Enter location (default: eastus): " LOCATION
LOCATION=${LOCATION:-eastus}

read -p "Enter PostgreSQL server name (must be globally unique): " POSTGRES_SERVER
read -p "Enter PostgreSQL admin username (default: admin): " POSTGRES_USER
POSTGRES_USER=${POSTGRES_USER:-admin}

read -s -p "Enter PostgreSQL admin password: " POSTGRES_PASSWORD
echo ""

read -p "Enter App Service name (must be globally unique): " APP_SERVICE_NAME

echo ""
echo "Creating resources..."

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create PostgreSQL server
echo "Creating PostgreSQL server..."
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $POSTGRES_SERVER \
  --location $LOCATION \
  --admin-user $POSTGRES_USER \
  --admin-password $POSTGRES_PASSWORD \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 15 \
  --storage-size 32 \
  --public-access 0.0.0.0

# Create database
echo "Creating database..."
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $POSTGRES_SERVER \
  --database-name animalguardian

# Create App Service Plan
echo "Creating App Service Plan..."
az appservice plan create \
  --name animalguardian-plan \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux

# Create Web App
echo "Creating Web App..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan animalguardian-plan \
  --name $APP_SERVICE_NAME \
  --runtime "PYTHON:3.11"

# Get connection string
CONNECTION_STRING="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}.postgres.database.azure.com:5432/animalguardian?sslmode=require"

# Generate secret key
SECRET_KEY=$(python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

# Configure app settings
echo "Configuring app settings..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    DATABASE_URL="$CONNECTION_STRING" \
    SECRET_KEY="$SECRET_KEY" \
    DEBUG="False" \
    ALLOWED_HOSTS="${APP_SERVICE_NAME}.azurewebsites.net,*.azurewebsites.net" \
    DJANGO_SETTINGS_MODULE="animalguardian.settings" \
    DEFAULT_FROM_EMAIL="mutesijosephine324@gmail.com"

# Get outbound IPs
echo "Getting App Service outbound IPs..."
OUTBOUND_IPS=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --query outboundIpAddresses \
  --output tsv)

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Add firewall rule to allow App Service to access PostgreSQL:"
echo "   az postgres flexible-server firewall-rule create \\"
echo "     --resource-group $RESOURCE_GROUP \\"
echo "     --name $POSTGRES_SERVER \\"
echo "     --rule-name AllowAppService \\"
echo "     --start-ip-address 0.0.0.0 \\"
echo "     --end-ip-address 0.0.0.0"
echo ""
echo "2. Deploy your code:"
echo "   - Go to Azure Portal → $APP_SERVICE_NAME → Deployment Center"
echo "   - Connect to GitHub and select your repository"
echo ""
echo "3. Run migrations after deployment:"
echo "   az webapp ssh --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME"
echo "   Then run: python manage.py migrate"
echo ""
echo "Your App Service URL: https://${APP_SERVICE_NAME}.azurewebsites.net"
echo ""

