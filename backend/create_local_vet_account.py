#!/usr/bin/env python
"""Create a local vet account in local database for testing."""
import os
import sys
import django

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User, VeterinarianProfile

phone_number = '0780480780'
password = 'Aggyirakiza123'
first_name = 'Aggy'
last_name = 'Irakiza'
email = None  # Add email if you have it

print("\n" + "="*60)
print("Creating Local Vet Account in Local Database")
print("="*60 + "\n")

# Check if user already exists
existing_user = User.objects.filter(phone_number=phone_number).first()

if existing_user:
    print(f"⚠️  User already exists: {existing_user.get_full_name()}")
    print(f"  Updating account...")
    
    # Update existing user
    existing_user.first_name = first_name
    existing_user.last_name = last_name
    existing_user.user_type = 'local_vet'
    existing_user.is_active = True
    existing_user.is_approved_by_admin = True  # Auto-approve for local testing
    existing_user.is_verified = True
    existing_user.set_password(password)
    existing_user.save()
    
    print(f"✓ Account updated successfully!")
    print(f"  - Phone: {existing_user.phone_number}")
    print(f"  - User type: {existing_user.user_type}")
    print(f"  - is_active: {existing_user.is_active}")
    print(f"  - is_approved: {existing_user.is_approved_by_admin}")
    
    user = existing_user
else:
    # Create new user
    username = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    
    user = User.objects.create_user(
        username=username,
        phone_number=phone_number,
        email=email,
        password=password,
        first_name=first_name,
        last_name=last_name,
        user_type='local_vet',
        is_active=True,
        is_approved_by_admin=True,  # Auto-approve for local testing
        is_verified=True
    )
    
    print(f"✓ Account created successfully!")
    print(f"  - Name: {user.get_full_name()}")
    print(f"  - Phone: {user.phone_number}")
    print(f"  - User type: {user.user_type}")
    print(f"  - is_active: {user.is_active}")
    print(f"  - is_approved: {user.is_approved_by_admin}")

# Create or update veterinarian profile
vet_profile, created = VeterinarianProfile.objects.get_or_create(
    user=user,
    defaults={
        'license_number': f'VET-{user.id}-LOCAL',
        'license_type': 'licensed',
        'specialization': 'General Practice',
        'is_available': False
    }
)

if created:
    print(f"✓ Veterinarian profile created")
else:
    print(f"✓ Veterinarian profile already exists")

print("\n" + "="*60)
print("✅ Account is ready for login!")
print("="*60)
print(f"\nYou can now login with:")
print(f"  Phone: {phone_number}")
print(f"  Password: {password}")
print("\n" + "="*60 + "\n")

