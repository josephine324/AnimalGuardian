"""
Script to fix users with empty string emails (convert to None).
This prevents UNIQUE constraint violations when multiple users have empty emails.
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def fix_empty_emails():
    """Convert all empty string emails to None."""
    users_with_empty_email = User.objects.filter(email='')
    count = users_with_empty_email.count()
    
    if count > 0:
        print(f"Found {count} user(s) with empty string email. Fixing...")
        updated = users_with_empty_email.update(email=None)
        print(f"Updated {updated} user(s). Empty emails converted to None.")
    else:
        print("No users with empty string email found.")
    
    # Also check for users with whitespace-only emails
    all_users = User.objects.all()
    fixed_count = 0
    for user in all_users:
        if user.email and isinstance(user.email, str) and not user.email.strip():
            user.email = None
            user.save(update_fields=['email'])
            fixed_count += 1
    
    if fixed_count > 0:
        print(f"Fixed {fixed_count} user(s) with whitespace-only emails.")
    
    print("Done!")

if __name__ == '__main__':
    fix_empty_emails()

