#!/bin/bash

# Digital Classroom Quiz - Azure App Service Deployment Script
# This script deploys the Flask application to Azure App Service with MongoDB Atlas

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

# Configuration - UPDATE THESE VALUES
APP_NAME="digital-classroom-quiz-$(date +%s)"
RESOURCE_GROUP="quizapp-rg"
LOCATION="East US"
PLAN_NAME="quizapp-plan"
SKU="FREE"  # Change to B1 for production

# MongoDB Atlas connection string (REPLACE WITH YOUR ACTUAL CONNECTION STRING)
MONGODB_URI="mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@YOUR_CLUSTER.mongodb.net/quizdb?retryWrites=true&w=majority"
SECRET_KEY="YOUR_SECRET_KEY_HERE"

echo "📋 Deployment Configuration:"
echo "   App Name: $APP_NAME"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"
echo "   Plan: $PLAN_NAME"
echo ""
echo "⚠️  IMPORTANT: Update the MongoDB URI and Secret Key above!"

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

# Configure environment variables
echo "⚙️  Configuring environment variables..."
az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --setting-names \
        "MONGO_URI=$MONGODB_URI" \
        "SECRET_KEY=$SECRET_KEY" \
        "FLASK_ENV=production" \
    --output none

# Configure deployment settings
echo "🔧 Configuring deployment settings..."
az webapp config set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --startup-file "startup.py" \
    --output none

# Enable always-on (for free tier, this keeps the app from sleeping)
if [ "$SKU" = "FREE" ]; then
    echo "💤 Note: Free tier may sleep after inactivity. Consider upgrading for production."
else
    az webapp config set \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --always-on true \
        --output none
fi

# Deploy code from local directory (assumes you're in the project directory)
echo "🚀 Deploying application code..."
echo "📝 Uploading files to Azure..."

# Create deployment zip
ZIP_FILE="deployment.zip"
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# Create zip excluding unnecessary files
zip -r "$ZIP_FILE" . \
    -x "*.git*" \
    -x "__pycache__/*" \
    -x "*.pyc" \
    -x ".vscode/*" \
    -x "*.log" \
    -x "node_modules/*" \
    -x ".env*" \
    -x "deployment.zip"

# Deploy to Azure
az webapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --src "$ZIP_FILE" \
    --output none

# Clean up
rm "$ZIP_FILE"

# Get deployment URL
DEPLOYMENT_URL="https://$APP_NAME.azurewebsites.net"

echo ""
echo "✅ Deployment Complete!"
echo "=========================="
echo "🌐 Application URL: $DEPLOYMENT_URL"
echo ""
echo "📋 Next Steps:"
echo "1. Test your application at: $DEPLOYMENT_URL"
echo "2. Verify MongoDB Atlas connection"
echo "3. Update environment variables if needed in Azure Portal"
echo "4. Set up custom domain (optional)"
echo ""
echo "🔧 Environment Variables Set:"
echo "   MONGO_URI: [configured]"
echo "   SECRET_KEY: [configured]"
echo "   FLASK_ENV: production"
echo ""
echo "📊 To monitor your app:"
echo "   az webapp log tail --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "🔄 To redeploy after changes:"
echo "   # Make your code changes"
echo "   # Run this script again"
echo ""
echo "🎉 Your Digital Classroom Quiz is now live on Azure!"
echo "   Students and teachers can access it from anywhere!"
