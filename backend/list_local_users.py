#!/usr/bin/env python
"""List all local users for development."""
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
print("Local Development Users")
print(f"{'='*60}\n")

users = User.objects.all().order_by('user_type', 'id')
for user in users:
    print(f"User ID: {user.id}")
    print(f"  Name: {user.get_full_name()}")
    print(f"  Email: {user.email or 'N/A'}")
    print(f"  Phone: {user.phone_number or 'N/A'}")
    print(f"  Username: {user.username}")
    print(f"  User Type: {user.user_type}")
    print(f"  Active: {user.is_active}, Approved: {user.is_approved_by_admin}, Verified: {user.is_verified}")
    print()

print(f"{'='*60}\n")

