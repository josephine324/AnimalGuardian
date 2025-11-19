#!/bin/bash
# Script to run database migration on Railway
# This should be run via Railway's terminal/web console

echo "Running database migrations on Railway..."
python manage.py migrate accounts 0006_rename_password_reset_code_to_token --verbosity=2
python manage.py migrate --verbosity=2
echo "Migrations completed!"

