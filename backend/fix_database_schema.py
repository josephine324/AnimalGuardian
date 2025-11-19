#!/usr/bin/env python
"""
Script to fix the database schema issue by renaming password_reset_code to password_reset_token.
This can be run manually on Railway if the migration doesn't run automatically.
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.db import connection
from django.core.management import call_command

def fix_schema():
    """Fix the database schema by renaming the column if needed."""
    print("Checking database schema...")
    
    try:
        with connection.cursor() as cursor:
            # Check if old column exists
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='users' AND column_name='password_reset_code'
            """)
            old_column_exists = cursor.fetchone() is not None
            
            # Check if new column exists
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='users' AND column_name='password_reset_token'
            """)
            new_column_exists = cursor.fetchone() is not None
        
        if old_column_exists and not new_column_exists:
            print("Found old column 'password_reset_code' but not 'password_reset_token'.")
            print("Renaming column...")
            
            # Rename the column directly in the database
            with connection.cursor() as cursor:
                cursor.execute("""
                    ALTER TABLE users 
                    RENAME COLUMN password_reset_code TO password_reset_token;
                """)
            
            print("✅ Successfully renamed password_reset_code to password_reset_token!")
            
        elif new_column_exists:
            print("✅ Column 'password_reset_token' already exists. Schema is correct.")
            
        elif not old_column_exists and not new_column_exists:
            print("⚠️  Neither column exists. This might be a new database.")
            print("Running migrations to create the column...")
            call_command('migrate', 'accounts', verbosity=2)
            
        else:
            print("✅ Schema appears to be correct.")
            
        # Run all migrations to ensure everything is up to date
        print("\nRunning all migrations to ensure database is up to date...")
        call_command('migrate', verbosity=2)
        print("✅ All migrations completed!")
        
    except Exception as e:
        print(f"❌ Error fixing schema: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    fix_schema()

