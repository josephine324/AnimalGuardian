#!/usr/bin/env python
"""Create a local vet user for local development."""
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

def create_local_vet():
    """Create a local vet user for local development."""
    phone_number = '+250788888888'
    email = 'localvet@test.com'
    password = 'Test@123456'
    first_name = 'Local'
    last_name = 'Veterinarian'
    
    print(f"\n{'='*60}")
    print("Creating/Updating Local Vet User for Local Development...")
    print(f"{'='*60}\n")
    print(f"Phone Number: {phone_number}")
    print(f"Email: {email}")
    print(f"Password: {password}\n")
    
    try:
        # Check if user exists by email or phone
        user = User.objects.filter(email=email).first()
        if not user:
            user = User.objects.filter(phone_number=phone_number).first()
        
        if user:
            print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
            print(f"Updating to local vet...")
            user.email = email
            user.phone_number = phone_number
            user.first_name = first_name
            user.last_name = last_name
            user.user_type = 'local_vet'
            user.is_active = True
            user.is_approved_by_admin = True  # Auto-approve for local development
            user.is_verified = True
            user.set_password(password)
            user.save()
            print(f"[OK] User updated to local vet")
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
                user_type='local_vet',
                is_active=True,
                is_approved_by_admin=True,  # Auto-approve for local development
                is_verified=True
            )
            print(f"[OK] Local vet user created successfully!")
        
        # Create or update veterinarian profile
        vet_profile, created = VeterinarianProfile.objects.get_or_create(
            user=user,
            defaults={
                'license_number': f'LVET-{user.id:04d}',
                'license_type': 'licensed',
                'specialization': 'General Practice',
                'clinic_name': 'Local Vet Clinic',
                'is_available': True
            }
        )
        if created:
            print(f"[OK] Veterinarian profile created")
        else:
            print(f"[OK] Veterinarian profile already exists")
            # Update profile to ensure it's set up correctly
            vet_profile.license_number = f'LVET-{user.id:04d}'
            vet_profile.is_available = True
            vet_profile.save()
        
        print(f"\n{'='*60}")
        print("Local Vet User Ready for Mobile App Login:")
        print(f"{'='*60}")
        print(f"Phone Number: {phone_number}")
        print(f"Email: {email}")
        print(f"Password: {password}")
        print(f"User Type: {user.user_type}")
        print(f"Is Active: {user.is_active}")
        print(f"Is Approved: {user.is_approved_by_admin}")
        print(f"Is Verified: {user.is_verified}")
        print(f"Is Available: {vet_profile.is_available}")
        print(f"License Number: {vet_profile.license_number}")
        print(f"\nYou can now login to the local mobile app as a local vet!")
        print(f"{'='*60}\n")
        
        return user
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    create_local_vet()

