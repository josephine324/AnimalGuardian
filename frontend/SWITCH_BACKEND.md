# How to Switch Between Local and Railway Backend

## Current Setup
Your `.env` file is configured to use Railway:
```
API_BASE_URL=https://animalguardian-backend-production-b5a8.up.railway.app/api
```

## Option 1: Use Local Backend (For Testing)

1. **Make sure your local backend is running:**
   ```powershell
   cd backend
   .\venv\Scripts\Activate.ps1
   $env:DATABASE_URL = $null  # Use SQLite locally
   python manage.py runserver
   ```

2. **Update `.env` file in `frontend` directory:**
   ```
   API_BASE_URL=http://localhost:8000/api
   ```

3. **Restart your Flutter app** (hot reload won't pick up .env changes)

## Option 2: Use Railway Backend (Production)

1. **Update `.env` file in `frontend` directory:**
   ```
   API_BASE_URL=https://animalguardian-backend-production-b5a8.up.railway.app/api
   ```

2. **Make sure Railway backend is running:**
   - Check Railway dashboard logs
   - Wait for deployment to complete
   - Verify the backend is responding

3. **Restart your Flutter app**

## Troubleshooting Railway 502 Error

If you see "502 Application failed to respond":

1. **Check Railway Logs:**
   - Go to Railway Dashboard → Your Service → Deployments → Latest → Logs
   - Look for migration errors or application crashes

2. **Common Issues:**
   - **Migration failing:** The migration might be stuck or failing
   - **Database connection:** PostgreSQL might be down
   - **App crashed:** Check for Python errors in logs

3. **Fix Migration Issues:**
   - Go to Railway Dashboard → Your Service → Deployments → Latest → Shell
   - Run: `python manage.py migrate --noinput`
   - Check for specific error messages

4. **Restart Service:**
   - Go to Railway Dashboard → Your Service → Settings
   - Click "Restart" or trigger a new deployment

## Quick Test: Is Backend Running?

**Test Railway:**
```powershell
Invoke-WebRequest -Uri "https://animalguardian-backend-production-b5a8.up.railway.app/api/" -UseBasicParsing
```

**Test Local:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8000/api/" -UseBasicParsing
```

If you get a response (even 404), the backend is running. If you get connection errors, it's down.

