#!/usr/bin/env python
"""Create a sector vet user for web dashboard access."""
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

def create_sector_vet():
    """Create a sector vet user."""
    email = 'r.uwitonze@alustudent.com'
    phone_number = '+250788888888'
    password = 'Test@123456'
    first_name = 'Rwema'
    last_name = 'Uwitonze'
    
    print(f"\n{'='*60}")
    print("Creating Sector Vet User...")
    print(f"{'='*60}\n")
    
    # Check if user already exists
    try:
        user = User.objects.filter(email=email).first()
        if not user:
            user = User.objects.filter(phone_number=phone_number).first()
        
        if user:
            print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
            print(f"Updating to sector vet...")
            user.email = email
            user.phone_number = phone_number
            user.first_name = first_name
            user.last_name = last_name
            user.user_type = 'sector_vet'
            user.is_active = True
            user.is_approved_by_admin = True
            user.is_verified = True
            user.is_staff = True
            user.set_password(password)
            user.save()
            print(f"[OK] User updated to sector vet")
        else:
            # Create new user
            username = email.split('@')[0]  # Use email prefix as username
            user = User.objects.create_user(
                username=username,
                email=email,
                phone_number=phone_number,
                password=password,
                first_name=first_name,
                last_name=last_name,
                user_type='sector_vet',
                is_active=True,
                is_approved_by_admin=True,
                is_verified=True,
                is_staff=True
            )
            print(f"[OK] Sector vet user created successfully!")
        
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
        print("Login Credentials for Web Dashboard:")
        print(f"{'='*60}")
        print(f"Email: {email}")
        print(f"Password: {password}")
        print(f"\nYou can now login to the web dashboard!")
        print(f"{'='*60}\n")
        
        return user
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    create_sector_vet()

