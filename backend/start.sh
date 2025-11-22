#!/bin/bash
# Don't use set -e here, we want to handle errors manually

# Skip duplicate email fix - migrations will handle it
# The fix script requires the table to exist, which may not be the case
echo "========================================="
echo "STEP 1: Running migrations (duplicate fix skipped)"
echo "========================================="
echo ""

# Run migrations (with verbosity for debugging)
# Only run migrations if needed (check if migrations are pending)
echo "========================================="
echo "STEP 2: Checking for pending migrations..."
echo "========================================="
python manage.py showmigrations --plan | grep -q "\[ \]" && HAS_PENDING=true || HAS_PENDING=false

if [ "$HAS_PENDING" = true ]; then
    echo "Pending migrations found. Running migrations..."
    python manage.py migrate --noinput --verbosity=1 || {
    echo "⚠ Standard migration failed, attempting recovery..."
    # If migration fails, try to fix duplicates again and retry
    echo "Re-running duplicate email fix..."
    python fix_duplicate_emails.py || true
    echo "Retrying migrations..."
    python manage.py migrate --noinput --verbosity=2 || {
        echo "⚠ Migration still failing, trying schema fix..."
    python fix_database_schema.py || {
            echo "⚠ Schema fix script failed, trying specific migration..."
        python manage.py migrate accounts 0006_rename_password_reset_code_to_token --noinput --verbosity=2 || true
        # Try all migrations again
            python manage.py migrate --noinput --verbosity=2 || {
                echo "❌ All migration attempts failed. Please check logs above."
                exit 1
            }
        }
    }
} else {
    echo "No pending migrations. Skipping migration step."
}

# Get port from environment variable, default to 8000
PORT=${PORT:-8000}

# Calculate optimal worker count based on available CPU cores
# Railway free tier typically has 1-2 cores, so use 2-4 workers
WORKERS=${WEB_CONCURRENCY:-4}
THREADS=${GUNICORN_THREADS:-2}
TIMEOUT=${GUNICORN_TIMEOUT:-120}

# Start gunicorn with optimized settings for Railway
# Workers: 4 (good for Railway free tier with 1-2 CPU cores)
# Threads: 2 per worker (allows handling multiple requests concurrently)
# Timeout: 120 seconds (Railway needs longer timeout for cold starts)
# Keep-alive: 5 seconds (reuse connections)
# Max requests: 1000 (restart workers periodically to prevent memory leaks)
# Preload: Load app before forking (faster startup, less memory per worker)
exec gunicorn animalguardian.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers $WORKERS \
    --threads $THREADS \
    --worker-class gthread \
    --timeout $TIMEOUT \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --preload \
    --access-logfile - \
    --error-logfile - \
    --log-level info

