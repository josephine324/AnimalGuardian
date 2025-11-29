#!/usr/bin/env python
"""Approve all users for local development."""
import os
import sys
import django

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']
django.setup()

from accounts.models import User

print(f"\n{'='*60}")
print("Approving All Users for Local Development...")
print(f"{'='*60}\n")

users = User.objects.all()
approved_count = 0

for user in users:
    updated = False
    if not user.is_approved_by_admin:
        user.is_approved_by_admin = True
        updated = True
    if not user.is_verified:
        user.is_verified = True
        updated = True
    if not user.is_active:
        user.is_active = True
        updated = True
    
    if updated:
        user.save()
        approved_count += 1
        print(f"[OK] Approved: {user.get_full_name()} ({user.user_type})")

if approved_count == 0:
    print("All users are already approved!")
else:
    print(f"\nApproved {approved_count} user(s)")

print(f"\n{'='*60}\n")

