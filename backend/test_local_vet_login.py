#!/usr/bin/env python
"""Test local vet login authentication."""
import os
import sys
import django

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']
django.setup()

from accounts.models import User
from django.contrib.auth import authenticate
import re

phone_number = '0780555261'
password = 'iturindesylvie123'

# Clean phone number (same as login view does)
cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
print(f"Original phone: {phone_number}")
print(f"Cleaned phone: {cleaned_phone}")

# Find user
user = User.objects.filter(phone_number=phone_number).first()
if user:
    print(f"\nUser found:")
    print(f"  Username: {user.username}")
    print(f"  Phone: {user.phone_number}")
    print(f"  Name: {user.get_full_name()}")
    print(f"  User Type: {user.user_type}")
    print(f"  Is Active: {user.is_active}")
    print(f"  Is Approved: {user.is_approved_by_admin}")
    print(f"  Is Verified: {user.is_verified}")
    
    # Test password
    password_check = user.check_password(password)
    print(f"\nPassword check: {password_check}")
    
    # Test authentication
    auth_user = authenticate(username=cleaned_phone, password=password)
    if auth_user:
        print(f"[OK] Authenticate SUCCESS: {auth_user.username}")
        print(f"[OK] Ready to login!")
    else:
        print(f"[FAIL] Authenticate FAILED")
        # Try with username
        auth_user2 = authenticate(username=user.username, password=password)
        if auth_user2:
            print(f"[OK] Authenticate with username SUCCESS: {auth_user2.username}")
        else:
            print(f"[FAIL] Authenticate with username FAILED")
else:
    print(f"\n[FAIL] User NOT found with phone: {phone_number}")

