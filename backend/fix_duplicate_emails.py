#!/usr/bin/env python
"""
Standalone script to fix duplicate emails in the database.
Run this BEFORE running migrations if migration 0008 fails.

Usage:
    python fix_duplicate_emails.py
"""

import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.db import connection, transaction

def fix_duplicate_emails():
    """Fix duplicate emails by setting all but the first occurrence to NULL."""
    with transaction.atomic():
        with connection.cursor() as cursor:
            if connection.vendor == 'postgresql':
            print("Checking for duplicate emails...")
            
            # First, check for duplicates
            cursor.execute("""
                SELECT email, COUNT(*) as count
                FROM accounts_user
                WHERE email IS NOT NULL AND email != ''
                GROUP BY email
                HAVING COUNT(*) > 1;
            """)
            duplicates = cursor.fetchall()
            
            if not duplicates:
                print("✓ No duplicate emails found. Database is clean!")
                return
            
            print(f"Found {len(duplicates)} duplicate email(s):")
            for email, count in duplicates:
                print(f"  - {email}: {count} occurrences")
            
            print("\nFixing duplicates (keeping first user, setting others to NULL)...")
            
            # Use window function to fix all duplicates at once
            try:
                cursor.execute("""
                    WITH ranked_users AS (
                        SELECT 
                            id,
                            email,
                            ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn
                        FROM accounts_user
                        WHERE email IS NOT NULL AND email != ''
                    )
                    UPDATE accounts_user
                    SET email = NULL
                    FROM ranked_users
                    WHERE accounts_user.id = ranked_users.id
                    AND ranked_users.rn > 1;
                """)
                rows_updated = cursor.rowcount
                print(f"✓ Updated {rows_updated} user(s) - set duplicate emails to NULL")
            except Exception as e:
                print(f"Window function approach failed: {e}")
                print("Trying alternative approach...")
                
                # Fallback: fix each duplicate email individually
                for email, count in duplicates:
                    cursor.execute("""
                        UPDATE accounts_user
                        SET email = NULL
                        WHERE id IN (
                            SELECT id FROM accounts_user
                            WHERE email = %s
                            ORDER BY id
                            OFFSET 1
                        );
                    """, [email])
                    print(f"  ✓ Fixed {email}: kept first user, set {count - 1} duplicate(s) to NULL")
            
            # Verify no duplicates remain
            cursor.execute("""
                SELECT email, COUNT(*) as count
                FROM accounts_user
                WHERE email IS NOT NULL AND email != ''
                GROUP BY email
                HAVING COUNT(*) > 1;
            """)
            remaining = cursor.fetchall()
            
            if remaining:
                print(f"\n⚠ WARNING: {len(remaining)} duplicate(s) still remain!")
                for email, count in remaining:
                    print(f"  - {email}: {count} occurrences")
            else:
                print("\n✓ All duplicates fixed! Database is now clean.")
            # Transaction will auto-commit on successful exit of atomic block
        else:
            print("This script only works with PostgreSQL. For SQLite, duplicates are handled differently.")
            sys.exit(1)

if __name__ == '__main__':
    try:
        fix_duplicate_emails()
        print("\n✓ Script completed successfully!")
        print("You can now run: python manage.py migrate")
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

