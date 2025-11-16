#!/usr/bin/env python3
"""
Create test users for all user types in AnimalGuardian
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User, FarmerProfile, VeterinarianProfile

def create_test_users():
    """Create test users for all user types"""
    
    users_created = []
    
    # Test Farmer 1
    try:
        farmer1, created = User.objects.get_or_create(
            phone_number='+250780000001',
            defaults={
                'username': 'farmer1',
                'email': 'farmer1@test.com',
                'first_name': 'John',
                'last_name': 'Farmer',
                'user_type': 'farmer',
                'is_verified': True,
                'is_approved_by_admin': True,
                'is_active': True
            }
        )
        if created:
            farmer1.set_password('Test@123456')
            farmer1.save()
            FarmerProfile.objects.get_or_create(
                user=farmer1,
                defaults={
                    'farm_name': 'Test Farm 1',
                    'farm_size': 5.0,
                    'farm_size_unit': 'hectares'
                }
            )
            users_created.append(('Farmer 1', farmer1.username, 'Test@123456'))
    except Exception as e:
        print(f"Error creating farmer1: {e}")
    
    # Test Farmer 2
    try:
        farmer2, created = User.objects.get_or_create(
            phone_number='+250780000002',
            defaults={
                'username': 'farmer2',
                'email': 'farmer2@test.com',
                'first_name': 'Jane',
                'last_name': 'Farmer',
                'user_type': 'farmer',
                'is_verified': True,
                'is_approved_by_admin': True,
                'is_active': True
            }
        )
        if created:
            farmer2.set_password('Test@123456')
            farmer2.save()
            FarmerProfile.objects.get_or_create(
                user=farmer2,
                defaults={
                    'farm_name': 'Test Farm 2',
                    'farm_size': 3.0,
                    'farm_size_unit': 'hectares'
                }
            )
            users_created.append(('Farmer 2', farmer2.username, 'Test@123456'))
    except Exception as e:
        print(f"Error creating farmer2: {e}")
    
    # Test Local Vet
    try:
        local_vet, created = User.objects.get_or_create(
            phone_number='+250780000003',
            defaults={
                'username': 'localvet1',
                'email': 'localvet1@test.com',
                'first_name': 'Dr. Local',
                'last_name': 'Vet',
                'user_type': 'local_vet',
                'is_verified': True,
                'is_approved_by_admin': True,
                'is_active': True
            }
        )
        if created:
            local_vet.set_password('Test@123456')
            local_vet.save()
            VeterinarianProfile.objects.get_or_create(
                user=local_vet,
                defaults={
                    'license_number': 'LVET001',
                    'license_type': 'licensed',
                    'specialization': 'General Practice',
                    'clinic_name': 'Local Vet Clinic',
                    'is_available': True
                }
            )
            users_created.append(('Local Vet', local_vet.username, 'Test@123456'))
    except Exception as e:
        print(f"Error creating local vet: {e}")
    
    # Test Sector Vet
    try:
        sector_vet, created = User.objects.get_or_create(
            phone_number='+250780000004',
            defaults={
                'username': 'sectorvet1',
                'email': 'sectorvet1@test.com',
                'first_name': 'Dr. Sector',
                'last_name': 'Vet',
                'user_type': 'sector_vet',
                'is_verified': True,
                'is_approved_by_admin': True,
                'is_active': True,
                'is_staff': True
            }
        )
        if created:
            sector_vet.set_password('Test@123456')
            sector_vet.save()
            VeterinarianProfile.objects.get_or_create(
                user=sector_vet,
                defaults={
                    'license_number': 'SVET001',
                    'license_type': 'licensed',
                    'specialization': 'Administration',
                    'clinic_name': 'Sector Vet Office',
                    'is_available': True
                }
            )
            users_created.append(('Sector Vet', sector_vet.username, 'Test@123456'))
    except Exception as e:
        print(f"Error creating sector vet: {e}")
    
    # Test Field Officer
    try:
        field_officer, created = User.objects.get_or_create(
            phone_number='+250780000005',
            defaults={
                'username': 'fieldofficer1',
                'email': 'fieldofficer1@test.com',
                'first_name': 'Field',
                'last_name': 'Officer',
                'user_type': 'field_officer',
                'is_verified': True,
                'is_approved_by_admin': True,
                'is_active': True
            }
        )
        if created:
            field_officer.set_password('Test@123456')
            field_officer.save()
            users_created.append(('Field Officer', field_officer.username, 'Test@123456'))
    except Exception as e:
        print(f"Error creating field officer: {e}")
    
    # Ensure Admin is approved
    try:
        admin = User.objects.filter(email='mutesijosephine324@gmail.com').first()
        if admin:
            admin.is_approved_by_admin = True
            admin.is_verified = True
            admin.save()
            print(f"Admin account approved: {admin.username}")
    except Exception as e:
        print(f"Error approving admin: {e}")
    
    print("\n" + "="*60)
    print("Test Users Created:")
    print("="*60)
    for user_type, username, password in users_created:
        print(f"{user_type}: {username} / {password}")
    print("="*60)
    
    return users_created

if __name__ == "__main__":
    create_test_users()

