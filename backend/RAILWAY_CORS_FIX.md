# Quick Fix for CORS on Railway (IMMEDIATE ACTION REQUIRED)

## The Problem
Your production frontend at `https://animalguards.netlify.app` cannot access the backend API due to CORS blocking.

## ⚡ QUICK FIX (Do This Now - Takes 2 Minutes)

### Step 1: Go to Railway Dashboard
1. Open https://railway.app
2. Log in to your account
3. Select your backend service: `animalguardian-backend-production`

### Step 2: Add Environment Variable
1. Click on your backend service
2. Go to the **"Variables"** tab
3. Click **"+ New Variable"**
4. Add:
   - **Variable Name**: `CORS_ALLOW_ALL_ORIGINS`
   - **Value**: `true`
5. Click **"Add"**

### Step 3: Redeploy
1. Go to the **"Deployments"** tab
2. Click the **"..."** menu on the latest deployment
3. Select **"Redeploy"**
4. Wait for deployment to complete (2-3 minutes)

### Step 4: Test
1. Go to https://animalguards.netlify.app
2. Try to log in
3. Check browser console (F12) - CORS errors should be gone!

## 🔧 PERMANENT FIX (After Quick Fix Works)

The code has been updated to properly handle CORS. To deploy:

1. **Commit the changes:**
   ```bash
   git add backend/animalguardian/settings.py
   git commit -m "Fix CORS configuration for production"
   git push
   ```

2. **Railway will auto-deploy** when you push to your main branch

3. **After deployment, you can remove the `CORS_ALLOW_ALL_ORIGINS=true` variable** if you want stricter CORS (the code now properly allows the Netlify domain)

## What the Code Changes Do

1. ✅ Always includes `https://animalguards.netlify.app` in allowed origins
2. ✅ Adds regex pattern for all Netlify preview deployments
3. ✅ Properly handles preflight OPTIONS requests
4. ✅ Includes all necessary CORS headers

## Verification

After setting the environment variable and redeploying, you should see:
- ✅ Login works
- ✅ API requests succeed
- ✅ No CORS errors in browser console

If you still see errors after redeploying, check:
1. The environment variable is set correctly (case-sensitive: `CORS_ALLOW_ALL_ORIGINS`)
2. The deployment completed successfully
3. The service is running (check Railway logs)

