#!/usr/bin/env python
"""Script to manually run the password_reset_token migration"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.core.management import call_command
from django.db import connection

def run_migration():
    print("Running migration to rename password_reset_code to password_reset_token...")
    
    try:
        # Check if the old column exists
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='users' AND column_name='password_reset_code'
            """)
            old_column_exists = cursor.fetchone() is not None
            
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='users' AND column_name='password_reset_token'
            """)
            new_column_exists = cursor.fetchone() is not None
        
        if old_column_exists and not new_column_exists:
            print("Old column exists, new column doesn't. Running migration...")
            # Run the specific migration
            call_command('migrate', 'accounts', '0006_rename_password_reset_code_to_token', verbosity=2)
            print("Migration completed successfully!")
        elif new_column_exists:
            print("New column already exists. Migration not needed.")
        else:
            print("Neither column exists. This is unusual.")
            
    except Exception as e:
        print(f"Error running migration: {e}")
        # Try to run all migrations
        print("Attempting to run all migrations...")
        call_command('migrate', verbosity=2)

if __name__ == '__main__':
    run_migration()

