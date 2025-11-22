#!/usr/bin/env python
"""
One-time script to auto-approve all existing sector vets that are pending approval.
This ensures all sector vets are approved as per the new registration logic.
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def auto_approve_sector_vets():
    """Auto-approve all sector vets that are currently pending approval."""
    pending_sector_vets = User.objects.filter(
        user_type='sector_vet',
        is_approved_by_admin=False
    )
    
    count = pending_sector_vets.count()
    
    if count == 0:
        print("[OK] No pending sector vets found. All sector vets are already approved.")
        return
    
    print(f"Found {count} sector vet(s) pending approval. Auto-approving...")
    
    updated = pending_sector_vets.update(is_approved_by_admin=True)
    
    print(f"[OK] Successfully auto-approved {updated} sector vet(s).")
    
    # List the approved users
    approved_users = User.objects.filter(
        user_type='sector_vet',
        is_approved_by_admin=True,
        id__in=[u.id for u in pending_sector_vets]
    )
    
    for user in approved_users:
        print(f"  - {user.get_full_name()} ({user.email or user.phone_number})")

if __name__ == '__main__':
    auto_approve_sector_vets()

