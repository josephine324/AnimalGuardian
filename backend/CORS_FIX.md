# CORS Configuration Fix for Production

## Problem
The production frontend at `https://animalguards.netlify.app` is being blocked by CORS when trying to access the backend at `https://animalguardian-backend-production-b5a8.up.railway.app`.

## Solution

### Option 1: Set Environment Variable on Railway (Recommended)
1. Go to your Railway project dashboard
2. Navigate to your backend service
3. Go to the "Variables" tab
4. Add a new environment variable:
   - **Name**: `CORS_ALLOW_ALL_ORIGINS`
   - **Value**: `true`
5. Redeploy the service

### Option 2: Add Specific Origin to Environment Variable
1. Go to Railway project dashboard
2. Navigate to your backend service
3. Go to the "Variables" tab
4. Add or update environment variable:
   - **Name**: `CORS_ALLOWED_ORIGINS`
   - **Value**: `https://animalguards.netlify.app`
5. Redeploy the service

### Option 3: Verify Current Settings
The code has been updated to:
- Always include `https://animalguards.netlify.app` in allowed origins
- Support regex pattern for all Netlify domains: `^https://.*\.netlify\.app$`
- Allow proper preflight requests with all necessary headers

## After Making Changes
1. Commit and push the changes to your repository
2. Railway will automatically redeploy
3. Or manually trigger a redeploy from Railway dashboard

## Testing
After deployment, test by:
1. Opening `https://animalguards.netlify.app` in a browser
2. Opening browser console (F12)
3. Checking that API requests succeed without CORS errors

## Current CORS Configuration
- Production frontend: `https://animalguards.netlify.app` (explicitly allowed)
- All Netlify preview deployments: `^https://.*\.netlify\.app$` (regex pattern)
- Local development: All localhost origins allowed when DEBUG=True

