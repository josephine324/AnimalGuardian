#!/bin/bash
# Don't use set -e here, we want to handle errors manually

# Skip duplicate email fix - migrations will handle it
# The fix script requires the table to exist, which may not be the case
echo "========================================="
echo "STEP 1: Running migrations (duplicate fix skipped)"
echo "========================================="
echo ""

# Run migrations (with verbosity for debugging)
echo "========================================="
echo "STEP 2: Running database migrations..."
echo "========================================="
python manage.py migrate --noinput --verbosity=2 || {
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
}

# Get port from environment variable, default to 8000
PORT=${PORT:-8000}

# Start gunicorn
exec gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT

