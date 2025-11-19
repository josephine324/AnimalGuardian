# Azure Environment Variables Reference

Copy these environment variables to Azure Portal → Web App → Configuration → Application settings

## Required Variables

### Database
```
DATABASE_URL=postgresql://username:password@your-postgres-server.postgres.database.azure.com:5432/animalguardian?sslmode=require
```
**How to get:** Azure Portal → PostgreSQL Server → Connection strings → Copy JDBC string and convert to Django format

### Django Core
```
SECRET_KEY=[Generate using: python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"]
DEBUG=False
ALLOWED_HOSTS=your-app-name.azurewebsites.net,*.azurewebsites.net
DJANGO_SETTINGS_MODULE=animalguardian.settings
```

### Email
```
DEFAULT_FROM_EMAIL=mutesijosephine324@gmail.com
```

### CORS Settings
```
CORS_ALLOWED_ORIGINS=https://animalguards.netlify.app,https://your-app-name.azurewebsites.net,http://localhost:3000,http://localhost:3001
CSRF_TRUSTED_ORIGINS=https://animalguards.netlify.app,https://your-app-name.azurewebsites.net
```

### Africa's Talking SMS
```
AFRICASTALKING_USERNAME=sandbox
AFRICASTALKING_API_KEY=atsk_1d0e0702b50384db6c669dce7574ef5971ddf7ebcc411a5a214c39354ad26b363dbc94e2
```

## Optional Variables

### Email Configuration (if using SMTP)
```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

## Quick Setup Steps

1. Go to Azure Portal → Your Web App → Configuration
2. Click "+ New application setting" for each variable above
3. Paste the Name and Value
4. Click "Save" at the top
5. Click "Continue" to restart the app

