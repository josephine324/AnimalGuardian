#!/usr/bin/env python
"""Check if a user exists and verify login credentials."""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User
from django.contrib.auth import authenticate

def check_user(phone_number=None, email=None, password=None):
    """Check if user exists and verify credentials."""
    print(f"\n{'='*60}")
    print("Checking user login credentials...")
    print(f"{'='*60}\n")
    
    user = None
    
    # Try to find user by phone number
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
        except User.DoesNotExist:
            print(f"✗ No user found with phone number: {phone_number}")
            return
        except User.MultipleObjectsReturned:
            print(f"⚠ Multiple users found with phone number: {phone_number}")
            users = User.objects.filter(phone_number=phone_number)
            for u in users:
                print(f"  - {u.get_full_name()} (ID: {u.id})")
            user = users.first()
    
    # Try to find user by email
    elif email:
        print(f"Looking for user with email: {email}")
        try:
            user = User.objects.get(email=email)
            print(f"✓ User found: {user.get_full_name()} (ID: {user.id})")
            print(f"  - Phone: {user.phone_number}")
            print(f"  - User Type: {user.user_type}")
            print(f"  - Is Active: {user.is_active}")
            print(f"  - Is Approved: {user.is_approved_by_admin}")
            print(f"  - Is Verified: {user.is_verified}")
        except User.DoesNotExist:
            print(f"✗ No user found with email: {email}")
            return
        except User.MultipleObjectsReturned:
            print(f"⚠ Multiple users found with email: {email}")
            users = User.objects.filter(email=email)
            for u in users:
                print(f"  - {u.get_full_name()} (ID: {u.id})")
            user = users.first()
    
    if not user:
        print("✗ No user found")
        return
    
    # Check password
    if password:
        print(f"\nVerifying password...")
        # Try authenticate first
        auth_user = authenticate(username=user.phone_number, password=password)
        if auth_user:
            print("✓ Password is correct (via authenticate)")
        elif user.check_password(password):
            print("✓ Password is correct (via check_password)")
        else:
            print("✗ Password is incorrect")
            print(f"\nNote: The stored password hash starts with: {user.password[:20]}...")
            print("If you need to reset the password, you can use:")
            print(f"  python manage.py shell")
            print(f"  >>> from accounts.models import User")
            print(f"  >>> user = User.objects.get(phone_number='{user.phone_number}')")
            print(f"  >>> user.set_password('your_new_password')")
            print(f"  >>> user.save()")
    
    # Check if user can login
    print(f"\n{'='*60}")
    print("Login Status Check:")
    print(f"{'='*60}")
    
    if not user.is_active:
        print("✗ User is NOT ACTIVE - cannot login")
    else:
        print("✓ User is active")
    
    if user.user_type == 'local_vet' and not user.is_approved_by_admin:
        print("✗ User is a LOCAL VET but NOT APPROVED - cannot login")
        print("  User needs approval from a sector veterinarian or admin")
    elif user.user_type == 'local_vet' and user.is_approved_by_admin:
        print("✓ User is approved")
    elif user.user_type != 'local_vet':
        print("✓ User type does not require approval")
    
    if not user.is_verified:
        print("⚠ User is not verified (but this may not block login)")
    else:
        print("✓ User is verified")
    
    print(f"\n{'='*60}\n")

if __name__ == '__main__':
    # Check the user from the login attempt
    phone_number = '0780570632'
    password = 'xyza123?'
    
    check_user(phone_number=phone_number, password=password)
    
    # Also list all users for debugging
    print(f"\n{'='*60}")
    print("All users in database:")
    print(f"{'='*60}\n")
    users = User.objects.all()
    if users.exists():
        for u in users:
            print(f"  - {u.get_full_name()} | Phone: {u.phone_number} | Email: {u.email or 'N/A'} | Type: {u.user_type} | Active: {u.is_active} | Approved: {u.is_approved_by_admin}")
    else:
        print("  No users found in database")
    print()

