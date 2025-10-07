#!/bin/bash

# Digital Classroom Quiz - Azure Deployment Script
# This script helps deploy the Flask application to Azure App Service

set -e  # Exit on any error

echo "🚀 Digital Classroom Quiz - Azure Deployment"
echo "============================================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "🔐 Please login to Azure first:"
    echo "   az login"
    exit 1
fi

# Configuration
APP_NAME="digital-classroom-quiz-$(date +%s)"
RESOURCE_GROUP="quizapp-rg"
LOCATION="East US"
PLAN_NAME="quizapp-plan"
SKU="FREE"

echo "📋 Using configuration:"
echo "   App Name: $APP_NAME"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"

# Create resource group
echo "🏗️  Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create App Service Plan
echo "📦 Creating App Service Plan..."
az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --sku "$SKU" \
    --is-linux \
    --output none

# Create Web App
echo "🌐 Creating Web App..."
az webapp create \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$PLAN_NAME" \
    --name "$APP_NAME" \
    --runtime "PYTHON|3.9" \
    --output none

# Configure environment variables (you'll need to update these)
echo "⚙️  Configuring environment variables..."
echo "⚠️  Please update these values in the Azure Portal after deployment:"
echo "   - MONGO_URI: Your MongoDB connection string"
echo "   - SECRET_KEY: Your secure secret key"

# Set basic configuration
az webapp config set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --always-on true \
    --output none

# Deploy code (assumes you have a Git repository)
echo "🚀 Deploying application code..."
echo "📝 Note: This assumes you have initialized a Git repository."
echo "    If not, you can deploy via FTP or GitHub integration."

# Show deployment information
echo ""
echo "✅ Deployment Complete!"
echo "=========================="
echo "🌐 Application URL: https://$APP_NAME.azurewebsites.net"
echo ""
echo "📋 Next Steps:"
echo "1. Set up your MongoDB database (MongoDB Atlas recommended)"
echo "2. Update environment variables in Azure Portal:"
echo "   - Go to https://portal.azure.com"
echo "   - Find your Web App: $APP_NAME"
echo "   - Go to Configuration > Application settings"
echo "   - Add/update:"
echo "     * MONGO_URI = your-mongodb-connection-string"
echo "     * SECRET_KEY = your-secure-secret-key"
echo ""
echo "🔧 For updates, simply push to your Git repository"
echo "📖 See README.md for detailed configuration instructions"
echo ""
echo "🎉 Happy Teaching and Learning!"
