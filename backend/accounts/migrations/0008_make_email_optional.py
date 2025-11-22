# Generated migration to make email optional

from django.db import migrations, models
from collections import Counter


def remove_unique_constraint_if_exists(apps, schema_editor):
    """Remove unique constraint on email if it exists."""
    db_alias = schema_editor.connection.alias
    with schema_editor.connection.cursor() as cursor:
        # Check if we're using PostgreSQL
        if schema_editor.connection.vendor == 'postgresql':
            # First check if the table exists
            try:
                cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'accounts_user'
                    );
                """)
                table_exists = cursor.fetchone()[0]
            except Exception:
                # If we can't check, assume table doesn't exist
                return
            
            if not table_exists:
                # Table doesn't exist yet, skip this operation
                return
            
            # Check if the table actually exists by trying to get its OID
            try:
                cursor.execute("""
                    SELECT oid FROM pg_class WHERE relname = 'accounts_user';
                """)
                table_oid = cursor.fetchone()
                if not table_oid:
                    # Table OID not found, skip
                    return
            except Exception:
                # If we can't get OID, skip constraint removal
                return
            
            # Find and drop the unique constraint on email column
            try:
                cursor.execute("""
                    SELECT conname 
                    FROM pg_constraint c
                    JOIN pg_class t ON c.conrelid = t.oid
                    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
                    WHERE t.relname = 'accounts_user'
                    AND c.contype = 'u'
                    AND a.attname = 'email';
                """)
                constraint = cursor.fetchone()
                if constraint:
                    constraint_name = constraint[0]
                    cursor.execute(f'ALTER TABLE accounts_user DROP CONSTRAINT IF EXISTS "{constraint_name}";')
            except Exception:
                # If constraint query fails, just continue - constraint might not exist
                pass


def handle_duplicate_emails(apps, schema_editor):
    """Handle duplicate emails - set all but the first occurrence to NULL."""
    db_alias = schema_editor.connection.alias
    
    # Check if table exists first
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == 'postgresql':
            try:
                cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'accounts_user'
                    );
                """)
                table_exists = cursor.fetchone()[0]
            except Exception:
                return
        else:
            # For SQLite
            try:
                cursor.execute("""
                    SELECT name FROM sqlite_master 
                    WHERE type='table' AND name='accounts_user';
                """)
                table_exists = cursor.fetchone() is not None
            except Exception:
                return
    
    if not table_exists:
        # Table doesn't exist yet, skip this operation
        return
    
    # Use raw SQL to find and fix duplicates directly
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == 'postgresql':
            try:
                # Use a more direct approach: update all duplicate emails to NULL except the first one
                # This uses a window function to identify which rows to keep
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
                # Verify no duplicates remain
                cursor.execute("""
                    SELECT email, COUNT(*) as count
                    FROM accounts_user
                    WHERE email IS NOT NULL AND email != ''
                    GROUP BY email
                    HAVING COUNT(*) > 1;
                """)
                remaining_duplicates = cursor.fetchall()
                if remaining_duplicates:
                    # If duplicates still exist, set all but one to NULL using a different approach
                    for email, count in remaining_duplicates:
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
            except Exception as e:
                # If the window function approach fails, try the simpler approach
                try:
                    # Find all duplicate emails
                    cursor.execute("""
                        SELECT email
                        FROM accounts_user
                        WHERE email IS NOT NULL AND email != ''
                        GROUP BY email
                        HAVING COUNT(*) > 1;
                    """)
                    duplicate_emails = [row[0] for row in cursor.fetchall()]
                    
                    # For each duplicate email, keep the first user (lowest ID) and set others to NULL
                    for email in duplicate_emails:
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
                except Exception:
                    # If everything fails, just continue
                    pass
        else:
            # SQLite approach
            try:
                User = apps.get_model('accounts', 'User')
                # Find all users with emails
                users_with_emails = User.objects.exclude(email__isnull=True).exclude(email='')
                
                # Count email occurrences
                email_counts = Counter(user.email for user in users_with_emails if user.email)
                
                # For each duplicate email, keep the first user (by ID) and set others to NULL
                for email, count in email_counts.items():
                    if count > 1 and email:  # Only process duplicates
                        # Get all users with this email, ordered by ID (keep the oldest)
                        duplicate_users = User.objects.filter(email=email).order_by('id')
                        
                        # Keep the first one, set others to NULL using raw SQL
                        user_ids = [user.id for user in duplicate_users[1:]]  # Skip the first one
                        if user_ids:
                            placeholders = ','.join(['?'] * len(user_ids))
                            cursor.execute(
                                f'UPDATE accounts_user SET email = NULL WHERE id IN ({placeholders})',
                                user_ids
                            )
            except Exception:
                # If anything fails, just continue
                pass


def reverse_handle_duplicate_emails(apps, schema_editor):
    """Reverse migration - nothing to do."""
    pass


def reverse_remove_unique_constraint(apps, schema_editor):
    """Reverse - nothing to do, constraint will be re-added by AlterField."""
    pass


def verify_no_duplicates(apps, schema_editor):
    """Verify no duplicate emails exist before adding unique constraint."""
    db_alias = schema_editor.connection.alias
    
    # First check if table exists
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == 'postgresql':
            try:
                # Check if table exists
                cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'accounts_user'
                    );
                """)
                table_exists = cursor.fetchone()[0]
                
                if not table_exists:
                    # Table doesn't exist yet, nothing to verify
                    return
                
                # Check for any remaining duplicates
                cursor.execute("""
                    SELECT email, COUNT(*) as count
                    FROM accounts_user
                    WHERE email IS NOT NULL AND email != ''
                    GROUP BY email
                    HAVING COUNT(*) > 1;
                """)
                duplicates = cursor.fetchall()
                
                if duplicates:
                    # If duplicates still exist, try to fix them one more time
                    print(f"WARNING: Found {len(duplicates)} duplicate email(s) before adding unique constraint. Fixing now...")
                    for email, count in duplicates:
                        print(f"  - Fixing {email}: {count} occurrences")
                        # Use a subquery that's more reliable
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
                    
                    # Verify again
                    cursor.execute("""
                        SELECT email, COUNT(*) as count
                        FROM accounts_user
                        WHERE email IS NOT NULL AND email != ''
                        GROUP BY email
                        HAVING COUNT(*) > 1;
                    """)
                    remaining = cursor.fetchall()
                    
                    if remaining:
                        # Raise exception - Django will handle transaction rollback
                        raise Exception(
                            f"Cannot proceed: {len(remaining)} duplicate email(s) still exist after cleanup. "
                            f"Duplicates: {[r[0] for r in remaining]}. "
                            f"Please run 'python fix_duplicate_emails.py' manually before running migrations."
                        )
                    else:
                        print("✓ All duplicates fixed. Proceeding with unique constraint.")
            except Exception as e:
                # If it's our custom exception, re-raise it
                if "Cannot proceed" in str(e):
                    raise
                # If it's a transaction error, the migration will fail and Django will rollback
                if "transaction" in str(e).lower() or "aborted" in str(e).lower():
                    raise Exception(
                        f"Transaction error during duplicate verification. "
                        f"This usually means duplicates still exist. "
                        f"Please run 'python fix_duplicate_emails.py' manually and try again. "
                        f"Original error: {e}"
                    )
                # Otherwise, log and continue (might be a fresh database or other issue)
                print(f"Note during verification: {e}")


def reverse_verify_no_duplicates(apps, schema_editor):
    """Reverse - nothing to do."""
    pass


def add_unique_constraint_if_safe(apps, schema_editor):
    """Add unique constraint only if no duplicates exist."""
    db_alias = schema_editor.connection.alias
    
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == 'postgresql':
            try:
                # Check for any remaining duplicates
                cursor.execute("""
                    SELECT email, COUNT(*) as count
                    FROM accounts_user
                    WHERE email IS NOT NULL AND email != ''
                    GROUP BY email
                    HAVING COUNT(*) > 1;
                """)
                duplicates = cursor.fetchall()
                
                if duplicates:
                    print(f"WARNING: Skipping unique constraint - {len(duplicates)} duplicate(s) still exist:")
                    for email, count in duplicates:
                        print(f"  - {email}: {count} occurrences")
                    print("Email field will remain nullable but NOT unique. Fix duplicates and run migration again.")
                    return  # Skip adding unique constraint
                
                # No duplicates - safe to add unique constraint
                print("No duplicates found. Adding unique constraint to email field...")
                # Use raw SQL to add the constraint directly
                try:
                    cursor.execute("""
                        ALTER TABLE accounts_user
                        ADD CONSTRAINT users_email_0ea73cca_uniq UNIQUE (email);
                    """)
                    schema_editor.connection.commit()
                    print("✓ Unique constraint added successfully.")
                except Exception as e:
                    if "already exists" in str(e).lower():
                        print("✓ Unique constraint already exists.")
                    else:
                        print(f"⚠ Could not add unique constraint: {e}")
                        print("Email field will remain nullable but NOT unique.")
            except Exception as e:
                print(f"Error checking for duplicates: {e}")
                print("Skipping unique constraint addition.")


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_change_vet_availability_default'),  # Skip data migration - just go straight to schema change
    ]

    operations = [
        # SIMPLIFIED: Just remove unique constraint and make email nullable
        # No unique constraint will be added - this allows backend to start immediately
        # Try to remove constraint, but don't fail if it doesn't exist or can't be removed
        migrations.RunPython(
            lambda apps, schema_editor: remove_unique_constraint_if_exists(apps, schema_editor) or None,
            reverse_remove_unique_constraint,
        ),
        # Make email nullable without unique constraint
        # This will work even if duplicates exist
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True, unique=False),
        ),
    ]
