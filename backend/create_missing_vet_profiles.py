#!/usr/bin/env python
"""
Create VeterinarianProfile for all veterinarians that don't have one.
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User, VeterinarianProfile
import secrets

def create_missing_profiles():
    """Create VeterinarianProfile for all vets without profiles."""
    vets = User.objects.filter(user_type__in=['local_vet', 'sector_vet'])
    
    created_count = 0
    skipped_count = 0
    
    print(f"\n{'='*70}")
    print(f"Creating Missing Veterinarian Profiles")
    print(f"{'='*70}\n")
    
    for vet in vets:
        try:
            # Check if profile already exists
            if hasattr(vet, 'vet_profile'):
                print(f"[SKIP] {vet.email} already has a profile")
                skipped_count += 1
                continue
            
            # Generate a unique license number
            license_number = f'VET-{vet.id}-{secrets.token_hex(4).upper()}'
            while VeterinarianProfile.objects.filter(license_number=license_number).exists():
                license_number = f'VET-{vet.id}-{secrets.token_hex(4).upper()}'
            
            # Create profile
            profile = VeterinarianProfile.objects.create(
                user=vet,
                license_number=license_number,
                license_type='licensed',
                specialization='General Practice',
                is_available=True
            )
            
            print(f"[OK] Created profile for {vet.email} (ID: {vet.id})")
            print(f"     License: {license_number}")
            created_count += 1
            
        except Exception as e:
            print(f"[FAIL] Error creating profile for {vet.email}: {str(e)}")
    
    print(f"\n{'='*70}")
    print(f"Summary:")
    print(f"  Created: {created_count}")
    print(f"  Skipped: {skipped_count}")
    print(f"  Total: {vets.count()}")
    print(f"{'='*70}\n")

if __name__ == '__main__':
    create_missing_profiles()

