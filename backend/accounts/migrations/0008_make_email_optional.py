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
    """Handle duplicate emails after making email field nullable."""
    db_alias = schema_editor.connection.alias
    
    # Check if table exists first
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == 'postgresql':
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'accounts_user'
                );
            """)
            table_exists = cursor.fetchone()[0]
        else:
            # For SQLite
            cursor.execute("""
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='accounts_user';
            """)
            table_exists = cursor.fetchone() is not None
    
    if not table_exists:
        # Table doesn't exist yet, skip this operation
        return
    
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
            
            # Keep the first one, set others to NULL using raw SQL to avoid model validation
            with schema_editor.connection.cursor() as cursor:
                user_ids = [user.id for user in duplicate_users[1:]]  # Skip the first one
                if user_ids:
                    placeholders = ','.join(['%s'] * len(user_ids))
                    cursor.execute(
                        f'UPDATE accounts_user SET email = NULL WHERE id IN ({placeholders})',
                        user_ids
                    )


def reverse_handle_duplicate_emails(apps, schema_editor):
    """Reverse migration - nothing to do."""
    pass


def reverse_remove_unique_constraint(apps, schema_editor):
    """Reverse - nothing to do, constraint will be re-added by AlterField."""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_change_vet_availability_default'),
    ]

    operations = [
        # Step 1: Remove unique constraint temporarily (to allow duplicates during migration)
        migrations.RunPython(
            remove_unique_constraint_if_exists,
            reverse_remove_unique_constraint,
        ),
        # Step 2: Alter the field to allow NULL (but not unique yet)
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True, unique=False),
        ),
        # Step 3: Handle duplicate emails (set extras to NULL)
        migrations.RunPython(
            handle_duplicate_emails,
            reverse_handle_duplicate_emails,
        ),
        # Step 4: Re-add unique constraint (PostgreSQL allows multiple NULLs with unique)
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True, unique=True),
        ),
    ]
