#!/bin/bash
# Don't use set -e here, we want to handle errors manually

# Fix duplicate emails before migrations (if they exist)
echo "========================================="
echo "STEP 1: Checking for duplicate emails..."
echo "========================================="
python fix_duplicate_emails.py
fix_exit_code=$?
if [ $fix_exit_code -eq 0 ]; then
    echo "✓ Duplicate email check completed successfully"
else
    echo "⚠ Duplicate email fix script had issues (exit code: $fix_exit_code), but continuing..."
fi
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

