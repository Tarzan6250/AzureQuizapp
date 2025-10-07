# Digital Classroom Quiz App - Azure Deployment Guide

## 🚀 Overview

This is a Flask-based Digital Classroom Quiz application that allows teachers to upload questions and students to take quizzes with instant scoring. The application is designed to be deployed on Azure App Service.

## 📋 Prerequisites

Before deploying to Azure, ensure you have:

1. **Azure Account**: Sign up at [portal.azure.com](https://portal.azure.com)
2. **Azure CLI**: Install from [docs.microsoft.com](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **MongoDB Database**: Set up either:
   - MongoDB Atlas (cloud) - Recommended for production
   - Local MongoDB (for testing)

## 🛠️ Azure Deployment Steps

### Step 1: Prepare Your Application

The application is already configured for Azure deployment with:
- ✅ `.gitignore` - Excludes unnecessary files
- ✅ `web.config` - IIS configuration for Windows App Service
- ✅ `requirements.txt` - Production dependencies
- ✅ `startup.py` - Application startup script
- ✅ Environment variable configuration

### Step 2: Set Up MongoDB

**Option A: MongoDB Atlas (Recommended)**
1. Create account at [mongodb.com/atlas](https://www.mongodb.com/atlas)
2. Create a free cluster
3. Get your connection string from "Connect" > "Connect your application"

**Option B: Local MongoDB (Testing)**
1. Install MongoDB locally
2. Use the default connection string: `mongodb://localhost:27017/quizdb`

### Step 3: Deploy to Azure App Service

#### Method 1: Using Azure CLI (Recommended)

```bash
# 1. Login to Azure
az login

# 2. Create a resource group
az group create --name quizapp-rg --location "East US"

# 3. Create an App Service Plan
az appservice plan create --name quizapp-plan --resource-group quizapp-rg --sku FREE --is-linux

# 4. Create the web app
az webapp create --resource-group quizapp-rg --plan quizapp-plan --name your-unique-app-name --runtime "PYTHON|3.9"

# 5. Configure environment variables
az webapp config appsettings set --resource-group quizapp-rg --name your-unique-app-name --setting-names MONGO_URI="your-mongodb-connection-string" SECRET_KEY="your-secret-key-here"

# 6. Deploy the application
az webapp deployment source config --name your-unique-app-name --resource-group quizapp-rg --repo-url https://github.com/yourusername/digital-classroom-quiz.git --branch main --manual-integration

# 7. Enable always-on (for free tier, this keeps the app from sleeping)
az webapp config set --name your-unique-app-name --resource-group quizapp-rg --always-on true
```

#### Method 2: Using Azure Portal

1. **Create App Service**:
   - Go to [portal.azure.com](https://portal.azure.com)
   - Click "Create a resource" > "Web App"
   - Choose your subscription and resource group
   - Name: `your-unique-app-name` (must be globally unique)
   - Runtime stack: Python 3.9
   - Operating System: Linux (recommended) or Windows
   - Region: Choose your preferred region

2. **Configure Environment Variables**:
   - In your Web App, go to "Configuration" > "Application settings"
   - Add these settings:
     ```
     MONGO_URI = "your-mongodb-connection-string"
     SECRET_KEY = "your-secret-key-here"
     FLASK_ENV = "production"
     ```

3. **Deploy Code**:
   - Go to "Deployment Center"
   - Choose "External Git" or "Local Git"
   - Connect your GitHub repository or upload files via FTP

### Step 4: Set Environment Variables

In Azure Portal, go to your Web App > Configuration > Application settings and add:

```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/quizdb
SECRET_KEY=your-very-secure-secret-key-change-this
FLASK_ENV=production
```

**Important**: Never commit your real SECRET_KEY to version control!

## 🌐 Accessing Your Application

Once deployed, your application will be available at:
`https://your-unique-app-name.azurewebsites.net`

## 📁 Project Structure

```
digital-classroom-quiz/
├── app.py              # Main Flask application
├── auth.py             # Authentication module
├── startup.py          # Azure startup script
├── requirements.txt    # Python dependencies
├── web.config          # IIS configuration
├── .gitignore         # Git ignore rules
└── templates/         # HTML templates
    ├── index.html
    ├── login.html
    ├── signup.html
    ├── upload.html
    ├── quiz.html
    └── result.html
```

## 🔧 Configuration

### Database Connection
- Update `MONGO_URI` in environment variables
- For MongoDB Atlas: `mongodb+srv://username:password@cluster.mongodb.net/quizdb`
- For local MongoDB: `mongodb://localhost:27017/quizdb`

### Security
- Change the `SECRET_KEY` in production
- Generate a secure key: `python -c "import secrets; print(secrets.token_hex(32))"`

## 🚨 Troubleshooting

### Common Issues:

1. **Application won't start**:
   - Check Application Logs in Azure Portal
   - Verify all environment variables are set
   - Ensure MongoDB connection string is correct

2. **Database connection fails**:
   - Whitelist Azure IP in MongoDB Atlas
   - Check network access settings
   - Verify connection string format

3. **Static files not loading**:
   - Ensure `web.config` is present
   - Check file permissions

4. **Out of memory**:
   - Upgrade to paid App Service Plan
   - Enable "Always On" setting

## 🔒 Security Best Practices

1. **Use HTTPS**: Enforced by default on Azure App Service
2. **Secure Secret Key**: Generate a strong, random secret key
3. **Database Security**:
   - Use MongoDB Atlas with authentication
   - Restrict network access
   - Use environment variables for credentials
4. **Update Dependencies**: Keep `requirements.txt` updated

## 📊 Monitoring

Monitor your application in Azure Portal:
- **Application Insights**: For detailed monitoring
- **Log Stream**: Real-time logs
- **Metrics**: Performance metrics
- **Alerts**: Set up notifications

## 💰 Cost Optimization

- **Free Tier**: Suitable for testing (with limitations)
- **Always On**: Enable for production to prevent cold starts
- **Scale Up**: Upgrade plan for better performance
- **MongoDB Atlas**: Start with free M0 cluster

## 🔄 Updates and Maintenance

To update your deployed application:

```bash
# Push changes to your Git repository
git add .
git commit -m "Update application"
git push origin main

# Azure will automatically redeploy
```

## 📞 Support

For Azure-specific issues:
- [Azure Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/azure-web-app)
- [Microsoft Support](https://azure.microsoft.com/en-us/support/)

## 🎯 Next Steps

After successful deployment:

1. **Test the application** thoroughly
2. **Set up custom domain** (optional)
3. **Configure SSL certificate** (handled automatically)
4. **Set up monitoring** and alerts
5. **Plan for scaling** based on usage

---

**Happy Deploying! 🚀**

Your Digital Classroom Quiz application is now ready to serve teachers and students worldwide!
