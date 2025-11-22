# Generated data migration to fix duplicate emails BEFORE schema change

from django.db import migrations


def fix_duplicate_emails_data(apps, schema_editor):
    """Fix duplicate emails by setting all but the first occurrence to NULL.
    
    This runs BEFORE the schema migration to ensure no duplicates exist
    when the unique constraint is added.
    """
    db_alias = schema_editor.connection.alias
    
    # Check if table exists
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
                    return
                
                # Find all duplicate emails
                cursor.execute("""
                    SELECT email, COUNT(*) as count
                    FROM accounts_user
                    WHERE email IS NOT NULL AND email != ''
                    GROUP BY email
                    HAVING COUNT(*) > 1;
                """)
                duplicates = cursor.fetchall()
                
                if not duplicates:
                    print("Data migration: No duplicate emails found.")
                    return
                
                print(f"Data migration: Found {len(duplicates)} duplicate email(s). Fixing...")
                
                # Fix each duplicate email
                total_fixed = 0
                for email, count in duplicates:
                    try:
                        # Get all user IDs with this email, ordered by ID
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
                                fixed_count = cursor.rowcount
                                total_fixed += fixed_count
                                print(f"  Fixed {email}: kept user ID {user_ids[0]}, set {fixed_count} duplicate(s) to NULL")
                    except Exception as e:
                        print(f"  Error fixing {email}: {e}")
                        # Try alternative approach
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
                            fixed_count = cursor.rowcount
                            total_fixed += fixed_count
                            print(f"  Fixed {email} (alternative): set {fixed_count} duplicate(s) to NULL")
                        except Exception as e2:
                            print(f"  Failed to fix {email}: {e2}")
                
                if total_fixed > 0:
                    print(f"Data migration: Fixed {total_fixed} duplicate email(s) total.")
                    # Commit explicitly
                    schema_editor.connection.commit()
                    
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
                        print(f"WARNING: {len(remaining)} duplicate(s) still remain after fix!")
                        for email, count in remaining:
                            print(f"  - {email}: {count} occurrences")
                    else:
                        print("Data migration: All duplicates fixed successfully.")
            except Exception as e:
                print(f"Data migration error: {e}")
                import traceback
                traceback.print_exc()


def reverse_fix_duplicate_emails_data(apps, schema_editor):
    """Reverse migration - nothing to do."""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_change_vet_availability_default'),
    ]

    operations = [
        migrations.RunPython(
            fix_duplicate_emails_data,
            reverse_fix_duplicate_emails_data,
        ),
    ]

