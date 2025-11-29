#!/usr/bin/env python
"""Create a user from production credentials for local development."""
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

from accounts.models import User, VeterinarianProfile

def create_production_user():
    """Create the user from production for local development."""
    email = 'mutesijosephine324@gmail.com'
    phone_number = '+250780570632'  # From create_superuser.py
    # You can change this password to match your production password
    # For now, we'll use a default that you can change
    password = 'Admin@123456'  # Default from create_superuser.py
    
    print(f"\n{'='*60}")
    print("Creating/Updating User for Local Development...")
    print(f"{'='*60}\n")
    print(f"Email: {email}")
    print(f"Note: Using default password. You can change it after login.")
    print(f"Default Password: {password}\n")
    
    try:
        # Check if user exists by email
        user = User.objects.filter(email=email).first()
        
        # If not found by email, check by phone
        if not user:
            user = User.objects.filter(phone_number=phone_number).first()
        
        if user:
            print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
            print(f"Updating user...")
            user.email = email
            user.phone_number = phone_number
            user.user_type = 'sector_vet'  # Ensure it's a sector vet for web dashboard
            user.is_active = True
            user.is_approved_by_admin = True
            user.is_verified = True
            user.is_staff = True
            user.is_superuser = True  # Make it admin/superuser
            user.set_password(password)
            user.save()
            print(f"[OK] User updated successfully")
        else:
            # Create new user
            username = email.split('@')[0]  # Use email prefix as username
            user = User.objects.create_superuser(
                username=username,
                email=email,
                phone_number=phone_number,
                password=password,
                first_name='Josephine',
                last_name='Mutesi',
                user_type='sector_vet',
                is_verified=True,
            )
            print(f"[OK] User created successfully!")
        
        # Create or update veterinarian profile
        vet_profile, created = VeterinarianProfile.objects.get_or_create(
            user=user,
            defaults={
                'license_number': f'SVET-{user.id:04d}',
                'license_type': 'licensed',
                'specialization': 'Administration',
                'is_available': True
            }
        )
        if created:
            print(f"[OK] Veterinarian profile created")
        else:
            print(f"[OK] Veterinarian profile already exists")
        
        print(f"\n{'='*60}")
        print("User Ready for Local Login:")
        print(f"{'='*60}")
        print(f"Email: {email}")
        print(f"Phone: {phone_number}")
        print(f"Password: {password}")
        print(f"User Type: {user.user_type}")
        print(f"Is Superuser: {user.is_superuser}")
        print(f"\nYou can now login to the local web dashboard!")
        print(f"\nIf you want to use your production password, you can:")
        print(f"1. Login with the default password above")
        print(f"2. Change password in the dashboard settings")
        print(f"3. Or run this script and modify the password variable")
        print(f"{'='*60}\n")
        
        return user
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    create_production_user()
