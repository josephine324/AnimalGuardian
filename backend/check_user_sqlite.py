#!/usr/bin/env python
"""Check user with SQLite database (force SQLite usage)."""
import os
import sys
import django

# Force SQLite before Django setup
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
# Remove DATABASE_URL to force SQLite
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']

# Override database settings before Django setup
import django.conf
django.conf.settings.configure(
    DATABASES={
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(os.path.dirname(__file__), 'db.sqlite3'),
        }
    },
    INSTALLED_APPS=[
        'django.contrib.auth',
        'django.contrib.contenttypes',
        'accounts',
    ],
    SECRET_KEY='temp-key-for-checking',
)

django.setup()

from accounts.models import User
from django.contrib.auth import authenticate

def check_user(phone_number=None, password=None):
    """Check if user exists and verify credentials."""
    print(f"\n{'='*60}")
    print("Checking user login credentials...")
    print(f"{'='*60}\n")
    
    if phone_number:
        print(f"Looking for user with phone number: {phone_number}")
        try:
            user = User.objects.get(phone_number=phone_number)
            print(f"✓ User found: {user.get_full_name()} (ID: {user.id})")
            print(f"  - Email: {user.email or 'Not set'}")
            print(f"  - User Type: {user.user_type}")
            print(f"  - Is Active: {user.is_active}")
            print(f"  - Is Approved: {user.is_approved_by_admin}")
            print(f"  - Is Verified: {user.is_verified}")
            
            if password:
                print(f"\nVerifying password...")
                auth_user = authenticate(username=user.phone_number, password=password)
                if auth_user:
                    print("✓ Password is correct (via authenticate)")
                elif user.check_password(password):
                    print("✓ Password is correct (via check_password)")
                else:
                    print("✗ Password is incorrect")
                    print(f"\nTo reset password, run:")
                    print(f"  python manage.py shell")
                    print(f"  >>> from accounts.models import User")
                    print(f"  >>> user = User.objects.get(phone_number='{user.phone_number}')")
                    print(f"  >>> user.set_password('your_new_password')")
                    print(f"  >>> user.save()")
            
            # Check login blockers
            print(f"\n{'='*60}")
            print("Login Status Check:")
            print(f"{'='*60}")
            
            blockers = []
            if not user.is_active:
                blockers.append("User is NOT ACTIVE")
            if user.user_type == 'local_vet' and not user.is_approved_by_admin:
                blockers.append("User is LOCAL VET but NOT APPROVED")
            
            if blockers:
                print("✗ Cannot login - Blockers:")
                for blocker in blockers:
                    print(f"  - {blocker}")
            else:
                print("✓ User can login")
                
        except User.DoesNotExist:
            print(f"✗ No user found with phone number: {phone_number}")
        except Exception as e:
            print(f"✗ Error: {e}")
    
    # List all users
    print(f"\n{'='*60}")
    print("All users in database:")
    print(f"{'='*60}\n")
    users = User.objects.all()
    if users.exists():
        for u in users:
            print(f"  - {u.get_full_name()} | Phone: {u.phone_number} | Type: {u.user_type} | Active: {u.is_active} | Approved: {u.is_approved_by_admin}")
    else:
        print("  No users found in database")
    print()

if __name__ == '__main__':
    check_user(phone_number='0780570632', password='xyza123?')

