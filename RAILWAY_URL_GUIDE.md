# How to Find Your Railway Backend URL

## Method 1: From Railway Dashboard (Easiest)

1. Go to your Railway project dashboard
2. Click on the **`animalguardian-backend`** service
3. Click on the **"Settings"** tab
4. Scroll down to the **"Domains"** section
5. You'll see your Railway-generated domain, which looks like:
   ```
   https://animalguardian-backend-production-xxxxx.up.railway.app
   ```
   or
   ```
   https://animalguardian-backend.railway.app
   ```

## Method 2: From Service Overview

1. Go to your Railway project dashboard
2. Click on the **`animalguardian-backend`** service
3. Look at the top of the service page - Railway often displays the URL there
4. Or check the **"Deployments"** tab - the URL might be shown in the deployment details

## Method 3: Generate a Custom Domain

1. Go to your Railway project → `animalguardian-backend` service
2. Click **"Settings"** tab
3. Scroll to **"Domains"** section
4. Click **"Generate Domain"** button
5. Railway will create a domain like: `animalguardian-backend-production.up.railway.app`

## Your Backend API Endpoints

Once you have your Railway URL, your API endpoints will be:

- **Base URL**: `https://your-backend-url.railway.app`
- **API Base**: `https://your-backend-url.railway.app/api`
- **Admin Panel**: `https://your-backend-url.railway.app/admin`
- **API Docs**: `https://your-backend-url.railway.app/api/docs`

## Update Netlify Configuration

After getting your Railway backend URL, update `netlify.toml`:

```toml
[build.environment]
REACT_APP_API_URL = "https://your-backend-url.railway.app/api"
```

Then redeploy your Netlify site.

## Test Your Backend

Test if your backend is working:

```bash
# Health check
curl https://your-backend-url.railway.app/api/

# Or visit in browser
https://your-backend-url.railway.app/admin
```

