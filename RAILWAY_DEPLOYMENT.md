# Railway Deployment Guide for AnimalGuardian

This guide will help you deploy the Backend API and USSD Service to Railway.

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **GitHub Repository**: Your code should be pushed to GitHub
3. **PostgreSQL Database**: Railway provides PostgreSQL as a service

## Step 1: Deploy Backend API (Django)

### 1.1 Create New Project on Railway

1. Go to [railway.app](https://railway.app) and log in
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your `AnimalGuardian` repository
5. Select the `backend` directory as the root directory

### 1.2 Add PostgreSQL Database

1. In your Railway project, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway will automatically create a PostgreSQL database
4. Note the connection details (you'll need them for environment variables)

### 1.3 Configure Environment Variables

Go to your backend service → **Variables** tab and add:

```env
# Django Settings
SECRET_KEY=your-secret-key-here-generate-a-random-string
DEBUG=False
ALLOWED_HOSTS=*.railway.app,your-custom-domain.com
DJANGO_SETTINGS_MODULE=animalguardian.settings

# Database (Railway automatically provides this)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# CORS Settings
CORS_ALLOWED_ORIGINS=https://your-netlify-app.netlify.app,https://your-custom-domain.com
CSRF_TRUSTED_ORIGINS=https://your-netlify-app.netlify.app,https://your-custom-domain.com

# Africa's Talking (for SMS/USSD)
AFRICASTALKING_USERNAME=your-africastalking-username
AFRICASTALKING_API_KEY=your-africastalking-api-key

# Email Settings (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=no-reply@animalguardian.rw

# Redis (if using Celery - optional)
REDIS_URL=${{Redis.REDIS_URL}}

# Static Files (Railway handles this automatically)
STATIC_URL=/static/
MEDIA_URL=/media/
```

### 1.4 Configure Build Settings

1. Go to **Settings** → **Build & Deploy**
2. **Root Directory**: `backend`
3. **Build Command**: (leave empty, Railway auto-detects)
4. **Start Command**: (leave empty, uses Procfile)

### 1.5 Deploy

1. Railway will automatically detect the `Procfile` and `requirements.txt`
2. Click **"Deploy"** or push to your GitHub repository
3. Wait for the build to complete
4. Your backend will be available at: `https://your-backend-service.railway.app`

### 1.6 Run Migrations

After first deployment, you may need to run migrations:

1. Go to your service → **Deployments** tab
2. Click on the latest deployment
3. Open **"View Logs"**
4. Or use Railway CLI:
   ```bash
   railway run python manage.py migrate
   railway run python manage.py createsuperuser
   railway run python manage.py collectstatic --noinput
   ```

---

## Step 2: Deploy USSD Service (Flask)

### 2.1 Create New Service

1. In the same Railway project, click **"+ New"**
2. Select **"GitHub Repo"**
3. Choose the same repository
4. Select the `ussd-service` directory as the root directory

### 2.2 Configure Environment Variables

Go to your USSD service → **Variables** tab and add:

```env
# Backend API URL (use your Railway backend URL)
BACKEND_API_URL=https://your-backend-service.railway.app/api

# Africa's Talking
AFRICASTALKING_USERNAME=your-africastalking-username
AFRICASTALKING_API_KEY=your-africastalking-api-key

# Flask Settings
FLASK_ENV=production
FLASK_APP=app.py
```

### 2.3 Configure Build Settings

1. Go to **Settings** → **Build & Deploy**
2. **Root Directory**: `ussd-service`
3. **Build Command**: (leave empty)
4. **Start Command**: (leave empty, uses Procfile)

### 2.4 Deploy

1. Railway will automatically detect the `Procfile` and `requirements.txt`
2. Click **"Deploy"** or push to your GitHub repository
3. Your USSD service will be available at: `https://your-ussd-service.railway.app`

---

## Step 3: Update Netlify Configuration

After deploying to Railway, update your `netlify.toml`:

```toml
[build.environment]
REACT_APP_API_URL = "https://your-backend-service.railway.app/api"
```

Then redeploy your Netlify site.

---

## Step 4: Configure Custom Domains (Optional)

### For Backend:

1. Go to your backend service → **Settings** → **Domains**
2. Click **"Generate Domain"** or **"Add Custom Domain"**
3. Update `ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` with your new domain

### For USSD Service:

1. Go to your USSD service → **Settings** → **Domains**
2. Click **"Generate Domain"** or **"Add Custom Domain"**
3. Update your Africa's Talking webhook URL to point to this domain

---

## Step 5: Verify Deployment

### Backend Health Check:
```bash
curl https://your-backend-service.railway.app/api/
```

### USSD Service Health Check:
```bash
curl https://your-ussd-service.railway.app/health
```

### Test Backend API:
```bash
curl https://your-backend-service.railway.app/api/auth/login/ \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"+250123456789","password":"test123"}'
```

---

## Troubleshooting

### Build Fails:
- Check Railway logs for errors
- Ensure all dependencies are in `requirements.txt`
- Verify Python version in `runtime.txt` matches Railway's supported versions

### Database Connection Issues:
- Verify `DATABASE_URL` is set correctly
- Check PostgreSQL service is running
- Ensure migrations have been run

### CORS Errors:
- Update `CORS_ALLOWED_ORIGINS` with your Netlify domain
- Check `ALLOWED_HOSTS` includes your Railway domain

### Static Files Not Loading:
- Run `python manage.py collectstatic --noinput` after deployment
- Check `STATIC_URL` and `STATIC_ROOT` settings

---

## Railway CLI (Optional)

Install Railway CLI for easier management:

```bash
npm i -g @railway/cli
railway login
railway link
railway up
```

---

## Cost Estimation

Railway offers:
- **Free Tier**: $5 credit/month
- **Hobby Plan**: $5/month per service
- **Pro Plan**: $20/month per service

For this project:
- Backend API: 1 service
- USSD Service: 1 service
- PostgreSQL: Included with service

**Estimated Cost**: $10-20/month (depending on usage)

---

## Support

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Project Issues: Check your GitHub repository

