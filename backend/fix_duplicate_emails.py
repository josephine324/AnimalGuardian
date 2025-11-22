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
    # Don't use transaction.atomic() - we want to commit immediately
    # so migrations can see the changes
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
            
            # Use a more direct approach: fix each duplicate email individually
            # This is more reliable than window functions
            rows_updated_total = 0
            for email, count in duplicates:
                try:
                    # First, get all user IDs with this email, ordered by ID
                    cursor.execute("""
                        SELECT id FROM accounts_user
                        WHERE email = %s
                        ORDER BY id;
                    """, [email])
                    user_ids = [row[0] for row in cursor.fetchall()]
                    
                    if len(user_ids) > 1:
                        # Keep the first one (lowest ID), set others to NULL
                        ids_to_null = user_ids[1:]
                        if ids_to_null:
                            placeholders = ','.join(['%s'] * len(ids_to_null))
                            cursor.execute(
                                f'UPDATE accounts_user SET email = NULL WHERE id IN ({placeholders})',
                                ids_to_null
                            )
                            rows_updated = cursor.rowcount
                            rows_updated_total += rows_updated
                            print(f"  ✓ Fixed {email}: kept user ID {user_ids[0]}, set {rows_updated} duplicate(s) to NULL")
                except Exception as e:
                    print(f"  ⚠ Error fixing {email}: {e}")
                    # Try alternative approach for this email
                    try:
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
                        rows_updated = cursor.rowcount
                        rows_updated_total += rows_updated
                        print(f"  ✓ Fixed {email} (alternative method): set {rows_updated} duplicate(s) to NULL")
                    except Exception as e2:
                        print(f"  ❌ Failed to fix {email} with both methods: {e2}")
            
            if rows_updated_total > 0:
                print(f"\n✓ Total: Updated {rows_updated_total} user(s) - set duplicate emails to NULL")
                # Explicitly commit the transaction
                connection.commit()
                print("✓ Changes committed to database")
            
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
                # Explicitly commit
                connection.commit()
                print("✓ Changes committed to database")
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

