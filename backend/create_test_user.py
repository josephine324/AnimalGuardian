#!/usr/bin/env python
"""Create a test user for login testing."""
import os
import sys
import django

# Use simple settings to avoid DATABASE_URL issues
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings_simple')

# Remove DATABASE_URL if set
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']

django.setup()

from accounts.models import User

def create_user():
    """Create test user."""
    phone_number = '0780570632'
    password = 'xyza123?'
    
    print(f"\n{'='*60}")
    print("Creating test user...")
    print(f"{'='*60}\n")
    
    # Check if user already exists
    try:
        user = User.objects.get(phone_number=phone_number)
        print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
        print(f"Resetting password...")
        user.set_password(password)
        user.is_active = True
        user.is_approved_by_admin = True
        user.is_verified = True
        user.save()
        print(f"[OK] Password reset and user activated")
        return user
    except User.DoesNotExist:
        pass
    
    # Create new user
    try:
        # Generate username from phone number
        username = phone_number.replace('+', '').replace('-', '').replace(' ', '')
        user = User.objects.create_user(
            username=username,
            phone_number=phone_number,
            password=password,
            first_name='Test',
            last_name='User',
            user_type='farmer',
            is_active=True,
            is_approved_by_admin=True,
            is_verified=True
        )
        print(f"[OK] User created successfully!")
        print(f"  - Phone: {user.phone_number}")
        print(f"  - Name: {user.get_full_name()}")
        print(f"  - Type: {user.user_type}")
        print(f"  - Active: {user.is_active}")
        print(f"  - Approved: {user.is_approved_by_admin}")
        print(f"  - Verified: {user.is_verified}")
        return user
    except Exception as e:
        print(f"Error creating user: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    user = create_user()
    if user:
        print(f"\n{'='*60}")
        print("Login Credentials:")
        print(f"{'='*60}")
        print(f"Phone Number: 0780570632")
        print(f"Password: xyza123?")
        print(f"\nYou can now login with these credentials!")
        print(f"{'='*60}\n")

