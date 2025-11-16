# Railway Deployment Fix

## Issue
Railway is not detecting Python/pip during the build process.

## Solution

### Option 1: Configure in Railway Dashboard (Recommended)

1. Go to your Railway project → `animalguardian-backend` service
2. Click on **Settings** tab
3. Scroll to **Build & Deploy** section
4. **Clear any custom build command** (leave it empty)
5. **Root Directory**: Make sure it's set to `backend`
6. **Start Command**: Leave empty (Railway will use Procfile)

Railway should auto-detect Python from:
- `requirements.txt` (in backend directory)
- `runtime.txt` (in backend directory)
- `Procfile` (in backend directory)

### Option 2: Manual Build Command

If auto-detection still doesn't work, set this in Railway dashboard:

**Build Command** (in Settings → Build & Deploy):
```bash
pip install --upgrade pip && pip install -r requirements.txt && python manage.py collectstatic --noinput
```

**Start Command** (leave empty or use):
```bash
python manage.py migrate --noinput && gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT
```

### Option 3: Use Nixpacks Configuration

The `nixpacks.toml` file has been created. Railway should use it automatically if present.

## Verify Configuration

Make sure these files exist in the `backend` directory:
- ✅ `requirements.txt`
- ✅ `runtime.txt` (with Python version: `3.11.7`)
- ✅ `Procfile` (with start command)
- ✅ `nixpacks.toml` (optional, for explicit build config)

## After Fixing

1. **Redeploy** the service in Railway
2. Check the **Logs** tab to see if Python is detected
3. The build should now succeed

## If Still Failing

1. Check that the **Root Directory** is set to `backend` (not root)
2. Verify all files are committed and pushed to GitHub
3. Try deleting and recreating the service
4. Check Railway logs for more specific errors

