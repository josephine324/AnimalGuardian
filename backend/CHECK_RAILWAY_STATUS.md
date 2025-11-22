# How to Check if Railway Backend is Running

## Quick Test: Health Endpoint

Test if the backend is responding:

1. **Open this URL in your browser:**
   ```
   https://animalguardian-backend-production-b5a8.up.railway.app/health/
   ```

2. **You should see:**
   ```json
   {"status": "healthy", "service": "animalguardian-backend", "cors_enabled": true}
   ```

3. **If you see:**
   - **"This site can't be reached"** → Backend is not running
   - **502 Bad Gateway** → Backend is crashing
   - **404 Not Found** → Backend is running but route doesn't exist
   - **JSON response** → ✅ Backend is running!

## Check Railway Dashboard

### Step 1: Go to Railway
1. Open: https://railway.app
2. Log in
3. Click on your project: **miraculous-victory**
4. Click on: **animalguardian-backend**

### Step 2: Check Deployment Status
1. Go to **"Deployments"** tab
2. Look at the **latest deployment**:
   - ✅ **"Active"** (green) = Backend is running
   - ❌ **"Crashed"** (red) = Backend is not running
   - ⏳ **"Building"** = Still deploying

### Step 3: Check Logs
1. Go to **"Logs"** tab
2. Look for:
   - **"CORS: Allowing all origins by default"** ← This confirms CORS is configured
   - **"Starting gunicorn"** or **"Booting worker"** ← Backend is starting
   - **"Operations to perform: Apply all migrations"** ← Migrations running
   - **Any red error messages** ← Something is wrong

### Step 4: Common Issues

#### Issue: "Crashed" Status
**Cause:** Migration is failing or backend is crashing on startup

**Solution:**
1. Check logs for the exact error
2. Look for "IntegrityError" or "duplicate emails"
3. The fix script should handle this automatically
4. If it doesn't, you may need to manually fix duplicates

#### Issue: "Building" Status (Stuck)
**Cause:** Deployment is taking too long

**Solution:**
1. Wait 5-10 minutes
2. Check if there are any build errors in logs
3. Try redeploying

#### Issue: Backend is Running but CORS Still Fails
**Cause:** Old code is deployed (before CORS fix)

**Solution:**
1. Check if latest commit is deployed
2. Look for "CORS: Allowing all origins" in logs
3. If not present, trigger a new deployment

## Force Redeploy

If the backend is stuck or you want to ensure latest code is deployed:

1. Go to **"Deployments"** tab
2. Click **"..."** (three dots) on latest deployment
3. Select **"Redeploy"**
4. Wait 3-5 minutes

## Test CORS Directly

You can test CORS using browser console:

1. Open: https://animalguards.netlify.app
2. Press **F12** to open developer tools
3. Go to **"Console"** tab
4. Run this command:
   ```javascript
   fetch('https://animalguardian-backend-production-b5a8.up.railway.app/health/', {
     method: 'GET',
     headers: {
       'Origin': 'https://animalguards.netlify.app'
     }
   })
   .then(r => r.json())
   .then(data => console.log('✅ CORS works!', data))
   .catch(err => console.error('❌ CORS failed:', err));
   ```

5. **If you see:**
   - ✅ **"CORS works!"** → CORS is configured correctly
   - ❌ **"CORS failed"** → Backend is not running or CORS not configured

## Next Steps Based on Results

### ✅ Backend is Running + CORS Works
- Everything is fine! Try logging in again

### ❌ Backend is Not Running
- Check Railway logs for errors
- Look for migration failures
- The fix script should handle duplicates automatically

### ⚠️ Backend is Running but CORS Fails
- Check if latest code is deployed
- Verify "CORS: Allowing all origins" appears in logs
- If not, redeploy or set `CORS_ALLOW_ALL_ORIGINS=true` environment variable

