# Manual Fix for Duplicate Emails on Railway

If the migration keeps failing, you can manually fix the duplicates using Railway CLI.

## Option 1: Use Railway CLI (Recommended)

### Step 1: Install Railway CLI
```powershell
npm install -g @railway/cli
```

### Step 2: Login and Link
```powershell
railway login
cd backend
railway link
```
Select your project and service when prompted.

### Step 3: Run the Fix Script
```powershell
railway run python fix_duplicate_emails.py
```

This will:
- Find duplicate emails
- Set all but the first user's email to NULL
- Commit the changes

### Step 4: Run Migrations
```powershell
railway run python manage.py migrate
```

### Step 5: Restart the Service
Go to Railway Dashboard → animalguardian-backend → Deployments → Click "..." → "Redeploy"

## Option 2: Direct SQL via Railway CLI

If the script doesn't work, you can run SQL directly:

### Step 1: Connect to Database
```powershell
railway connect postgres
```

### Step 2: Run SQL Commands
Once connected, run:
```sql
-- Check for duplicates
SELECT email, COUNT(*) as count
FROM accounts_user
WHERE email IS NOT NULL AND email != ''
GROUP BY email
HAVING COUNT(*) > 1;

-- Fix duplicates (replace 'gadrwagasana@gmail.com' with the actual duplicate email)
UPDATE accounts_user
SET email = NULL
WHERE id IN (
    SELECT id FROM accounts_user
    WHERE email = 'gadrwagasana@gmail.com'
    ORDER BY id
    OFFSET 1
);

-- Verify no duplicates remain
SELECT email, COUNT(*) as count
FROM accounts_user
WHERE email IS NOT NULL AND email != ''
GROUP BY email
HAVING COUNT(*) > 1;
```

### Step 3: Exit and Redeploy
```sql
\q
```

Then redeploy the service in Railway Dashboard.

## Option 3: Use Railway Database Tab

1. Go to Railway Dashboard
2. Click on **animalguardian-postgres** service
3. Go to **"Data"** or **"Query"** tab
4. Run the SQL commands from Option 2

## After Fixing

Once duplicates are fixed:
1. Go to Railway Dashboard → animalguardian-backend
2. Click **"Deployments"** tab
3. Click **"..."** on latest deployment
4. Select **"Redeploy"**
5. Wait 3-5 minutes
6. Check **"Logs"** to confirm migration succeeds
7. Test health endpoint: https://animalguardian-backend-production-b5a8.up.railway.app/health/

## Verify It Worked

After redeploying, check:
1. **Health endpoint** returns JSON (not "Application failed to respond")
2. **Logs show**: "Applying accounts.0008_make_email_optional... OK"
3. **No CORS errors** when logging in

