# How to Fix Duplicate Emails on Railway

The migration is failing because there are duplicate emails in the database. Here's how to fix it:

## Option 1: Use Railway CLI (Recommended)

### Step 1: Install Railway CLI

Open PowerShell or Terminal and run:
```powershell
npm install -g @railway/cli
```

### Step 2: Login to Railway

```powershell
railway login
```
This will open your browser for authentication.

### Step 3: Link to Your Project

```powershell
cd C:\Users\Administrator\Downloads\AnimalGuardian\backend
railway link
```
Select your project (`miraculous-victory`) and service (`animalguardian-backend`) when prompted.

### Step 4: Run the Fix Script

```powershell
railway run python fix_duplicate_emails.py
```

This will:
- Find all duplicate emails
- Keep the first user (lowest ID) with each email
- Set duplicate emails to NULL
- Verify the fix worked

### Step 5: Run Migrations

```powershell
railway run python manage.py migrate
```

## Option 2: Add as Release Command (Automatic Fix)

If you want Railway to automatically fix duplicates before migrations:

1. Go to Railway Dashboard → `animalguardian-backend` service
2. Click **"Settings"** tab
3. Scroll to **"Deploy"** section
4. Find **"Release Command"** field
5. Add this command:
   ```
   python fix_duplicate_emails.py && python manage.py migrate
   ```
6. Click **"Save"**
7. Trigger a new deployment (push to GitHub or click "Redeploy")

## Option 3: Check Logs First

Before fixing, check what the exact error is:

1. In Railway Dashboard, click on **"Logs"** tab (next to "Architecture")
2. Look for the error message
3. You should see: `IntegrityError: could not create unique index "users_email_0ea73cca_uniq" DETAIL: Key (email)=(gadrwagasana@gmail.com) is duplicated.`

## Option 4: Manual Database Access (Advanced)

If you have PostgreSQL client installed:

1. Go to Railway Dashboard → `animalguardian-postgres` service
2. Click **"Connect"** tab
3. Copy the connection string
4. Use a PostgreSQL client (like pgAdmin, DBeaver, or `psql`) to connect
5. Run this SQL:
   ```sql
   UPDATE accounts_user
   SET email = NULL
   WHERE id IN (
       SELECT id FROM accounts_user
       WHERE email = 'gadrwagasana@gmail.com'
       ORDER BY id
       OFFSET 1
   );
   ```

## After Fixing

Once duplicates are fixed:

1. The migration should run successfully
2. Your backend will deploy
3. CORS will work (because the backend will be running)
4. Frontend can connect to the backend

## Verify It Worked

After running the fix script, you should see:
```
✓ No duplicate emails found. Database is clean!
✓ Script completed successfully!
```

Then migrations should run without errors.

