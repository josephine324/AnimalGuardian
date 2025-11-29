#!/usr/bin/env python
"""Create a mobile app user for local development."""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
# Unset DATABASE_URL to use SQLite
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']
django.setup()

from accounts.models import User, FarmerProfile

def create_mobile_user():
    """Create the mobile app user for local development."""
    phone_number = '0783563395'
    password = 'mbabaziodeth123'
    email = None  # Can be added later if needed
    
    print(f"\n{'='*60}")
    print("Creating/Updating Mobile App User for Local Development...")
    print(f"{'='*60}\n")
    print(f"Phone Number: {phone_number}")
    print(f"Password: {password}\n")
    
    try:
        # Check if user exists by phone number
        user = User.objects.filter(phone_number=phone_number).first()
        
        if user:
            print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
            print(f"Updating user...")
            user.phone_number = phone_number
            user.user_type = 'farmer'  # Default to farmer for mobile app
            user.is_active = True
            user.is_approved_by_admin = True
            user.is_verified = True
            user.set_password(password)
            user.save()
            print(f"[OK] User updated successfully")
        else:
            # Create new user
            username = phone_number.replace('+', '').replace('-', '').replace(' ', '')
            user = User.objects.create_user(
                username=username,
                phone_number=phone_number,
                email=email,
                password=password,
                first_name='Mobile',
                last_name='User',
                user_type='farmer',  # Default to farmer, can be changed
                is_active=True,
                is_approved_by_admin=True,
                is_verified=True
            )
            print(f"[OK] User created successfully!")
        
        # Create or update farmer profile
        farmer_profile, created = FarmerProfile.objects.get_or_create(
            user=user,
            defaults={
                'farm_name': 'Local Test Farm',
                'farm_size': 1.0,
                'farm_size_unit': 'hectares'
            }
        )
        if created:
            print(f"[OK] Farmer profile created")
        else:
            print(f"[OK] Farmer profile already exists")
        
        print(f"\n{'='*60}")
        print("User Ready for Mobile App Login:")
        print(f"{'='*60}")
        print(f"Phone Number: {phone_number}")
        print(f"Password: {password}")
        print(f"User Type: {user.user_type}")
        print(f"Is Active: {user.is_active}")
        print(f"Is Approved: {user.is_approved_by_admin}")
        print(f"Is Verified: {user.is_verified}")
        print(f"\nYou can now login to the local mobile app!")
        print(f"{'='*60}\n")
        
        return user
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    create_mobile_user()

