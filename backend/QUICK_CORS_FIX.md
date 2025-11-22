# ⚡ QUICK CORS FIX - Do This Now!

## The Problem
Your frontend at `https://animalguards.netlify.app` cannot access the backend API due to CORS blocking.

## Solution: Set Environment Variable on Railway

### Step 1: Go to Railway Dashboard
1. Open https://railway.app
2. Log in
3. Click on your project: **miraculous-victory**
4. Click on **animalguardian-backend** service

### Step 2: Add Environment Variable
1. Click the **"Variables"** tab (next to "Deployments", "Metrics", "Settings")
2. Click **"+ New Variable"** button
3. Add:
   - **Variable Name**: `CORS_ALLOW_ALL_ORIGINS`
   - **Value**: `true`
4. Click **"Add"** or **"Save"**

### Step 3: Redeploy
1. Go to **"Deployments"** tab
2. Find the latest deployment (the one that's crashed or failed)
3. Click the **"..."** (three dots) menu on the right
4. Select **"Redeploy"**
5. Wait 2-3 minutes for deployment to complete

### Step 4: Verify
1. Go to **"Logs"** tab
2. You should see:
   - "CORS: Allowing all origins (CORS_ALLOW_ALL_ORIGINS=true)"
   - Migration running successfully
   - Server starting
3. Go to https://animalguards.netlify.app
4. Try to log in
5. Check browser console (F12) - CORS errors should be gone!

## Alternative: If You Can't Find Variables Tab

If you don't see a "Variables" tab:
1. Go to **"Settings"** tab
2. Scroll down to **"Environment Variables"** section
3. Click **"+ New Variable"**
4. Add `CORS_ALLOW_ALL_ORIGINS` = `true`
5. Save and redeploy

## Why This Works

Setting `CORS_ALLOW_ALL_ORIGINS=true` tells Django to:
- Accept requests from ANY origin (including Netlify)
- Send proper CORS headers in responses
- Handle preflight OPTIONS requests correctly

This is safe for your use case since you're using JWT authentication (not cookies), so CORS credentials are handled separately.

## After It Works

Once CORS is working, you can optionally:
1. Remove `CORS_ALLOW_ALL_ORIGINS=true` 
2. The code already includes `https://animalguards.netlify.app` in allowed origins
3. But keeping it as `true` is fine and makes it easier for future deployments

