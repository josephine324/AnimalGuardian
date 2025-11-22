#!/usr/bin/env python
"""
Script to fix the tag_number unique constraint issue on Render/production.
This converts all empty string tag_numbers to NULL and updates the database schema.
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

def fix_tag_number_issue():
    print("=" * 70)
    print("Fixing tag_number unique constraint issue...")
    print("=" * 70)
    
    try:
        with connection.cursor() as cursor:
            # Step 1: Check current state
            print("\n1. Checking current state...")
            cursor.execute("""
                SELECT COUNT(*) 
                FROM livestock 
                WHERE tag_number = '' OR tag_number IS NULL
            """)
            empty_count = cursor.fetchone()[0]
            print(f"   Found {empty_count} records with empty or NULL tag_number")
            
            # Step 2: Convert empty strings to NULL
            print("\n2. Converting empty strings to NULL...")
            cursor.execute("""
                UPDATE livestock 
                SET tag_number = NULL 
                WHERE tag_number = ''
            """)
            updated_count = cursor.rowcount
            print(f"   Updated {updated_count} records")
            
            # Step 3: Check if field allows NULL
            print("\n3. Checking if field allows NULL...")
            cursor.execute("""
                SELECT is_nullable 
                FROM information_schema.columns 
                WHERE table_name = 'livestock' 
                AND column_name = 'tag_number'
            """)
            result = cursor.fetchone()
            if result:
                is_nullable = result[0]
                print(f"   Field nullable status: {is_nullable}")
                
                if is_nullable == 'NO':
                    print("\n4. Updating field to allow NULL...")
                    # For PostgreSQL
                    cursor.execute("""
                        ALTER TABLE livestock 
                        ALTER COLUMN tag_number DROP NOT NULL
                    """)
                    print("   Field updated to allow NULL")
                else:
                    print("   Field already allows NULL")
            else:
                print("   Could not check field status (might be SQLite)")
        
        # Step 4: Run the migration to ensure everything is in sync
        print("\n5. Running migrations to ensure schema is up to date...")
        call_command('migrate', 'livestock', verbosity=2)
        
        print("\n" + "=" * 70)
        print("✅ Fix completed successfully!")
        print("=" * 70)
        print("\nYou can now add livestock with empty tag numbers.")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        print("\nTrying alternative approach...")
        
        # Try running the migration directly
        try:
            print("Running migration 0002_allow_null_tag_number...")
            call_command('migrate', 'livestock', '0002_allow_null_tag_number', verbosity=2)
            print("✅ Migration completed!")
        except Exception as e2:
            print(f"❌ Migration also failed: {e2}")
            print("\nPlease run manually on Render:")
            print("  python manage.py migrate livestock")

if __name__ == '__main__':
    fix_tag_number_issue()

