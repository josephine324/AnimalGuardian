# How to Run the Migration on Railway to Fix tag_number Issue

The livestock creation is failing because the database has empty string `tag_number` values that violate the unique constraint. We need to run a migration on Railway to fix this.

## Option 1: Run Migration via Railway CLI (Recommended)

1. **Install Railway CLI** (if not already installed):
   ```bash
   npm install -g @railway/cli
   ```

2. **Login to Railway**:
   ```bash
   railway login
   ```

3. **Link to your project**:
   ```bash
   railway link
   ```

4. **Run the migration**:
   ```bash
   railway run python manage.py migrate livestock
   ```

   Or run the fix script:
   ```bash
   railway run python fix_tag_number_issue.py
   ```

## Option 2: Run Migration via Railway Dashboard

1. Go to your Railway project dashboard
2. Click on your backend service
3. Go to the "Deployments" tab
4. Click on the latest deployment
5. Open the "Shell" or "Console" tab
6. Run:
   ```bash
   python manage.py migrate livestock
   ```

## Option 3: Add Migration to Startup Script

You can modify your `start.sh` or `Procfile` to automatically run migrations on startup:

**For start.sh:**
```bash
#!/bin/bash
set -e

# Run migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Start gunicorn
exec gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT
```

**For Procfile:**
```
release: python manage.py migrate
web: gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT
```

## Option 4: Use Railway's One-Click Deploy with Migration

1. Push your code to GitHub (make sure the migration file `0002_allow_null_tag_number.py` is included)
2. Railway will automatically detect the new migration
3. Add a release command in Railway settings:
   - Go to your service settings
   - Add a "Release Command": `python manage.py migrate`
   - This will run migrations before each deployment

## What the Migration Does

The migration `0002_allow_null_tag_number.py` will:
1. Convert all existing empty string `tag_number` values to `NULL`
2. Update the database schema to allow `NULL` values for `tag_number`
3. This allows multiple livestock records to have `NULL` tag numbers (standard SQL behavior)

## Verify the Fix

After running the migration, test by:
1. Trying to add livestock with an empty tag number
2. It should work without the unique constraint violation error

## Important Notes

- **Backup your database first** (if possible) before running migrations on production
- The migration is safe and only converts empty strings to NULL
- Multiple NULL values are allowed in SQL (unlike empty strings)
- The code changes we made ensure new empty strings are converted to NULL before saving

