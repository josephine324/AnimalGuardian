#!/usr/bin/env python
"""Test login with specific credentials"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.contrib.auth import authenticate
from accounts.models import User

def test_login(email, password):
    print(f"\n{'='*60}")
    print(f"Testing login for email: {email}")
    print(f"{'='*60}\n")
    
    # Step 1: Check if user exists
    print("Step 1: Checking if user exists...")
    user_obj = User.objects.filter(email=email).only('id', 'email', 'phone_number', 'username', 'user_type', 'is_active', 'is_verified', 'is_approved_by_admin').first()
    
    if not user_obj:
        print(f"[ERROR] No user found with email: {email}")
        return False
    
    print(f"[OK] User found!")
    print(f"   - ID: {user_obj.id}")
    print(f"   - Email: {user_obj.email}")
    print(f"   - Phone Number: {user_obj.phone_number}")
    print(f"   - Username: {user_obj.username}")
    print(f"   - User Type: {user_obj.user_type}")
    print(f"   - Is Active: {user_obj.is_active}")
    print(f"   - Is Verified: {user_obj.is_verified}")
    print(f"   - Is Approved: {user_obj.is_approved_by_admin}")
    
    # Step 2: Check phone_number
    if not user_obj.phone_number:
        print(f"\n[ERROR] User has no phone_number set!")
        print("   Authentication requires phone_number as USERNAME_FIELD")
        return False
    
    # Step 3: Check password directly
    print(f"\nStep 2: Checking password...")
    password_check = user_obj.check_password(password)
    print(f"   Password check result: {'PASSED' if password_check else 'FAILED'}")
    
    if not password_check:
        print(f"\n[ERROR] Password is incorrect!")
        print(f"   The password you provided doesn't match the stored hash")
        return False
    
    # Step 4: Try authentication
    print(f"\nStep 3: Attempting authentication...")
    print(f"   Using phone_number as username: {user_obj.phone_number}")
    
    user = authenticate(username=user_obj.phone_number, password=password)
    
    if user:
        print(f"\n[OK] Authentication SUCCESSFUL!")
        print(f"   - Authenticated User ID: {user.id}")
        print(f"   - Email: {user.email}")
        print(f"   - Phone: {user.phone_number}")
        print(f"   - User Type: {user.user_type}")
        return True
    else:
        print(f"\n[ERROR] Authentication FAILED!")
        print(f"   Password check passed, but authenticate() returned None")
        print(f"   This might indicate an issue with the authentication backend")
        return False

if __name__ == '__main__':
    email = 'j.mutesi@alustudent.com'
    password = '91073@Tecy'
    
    print(f"Testing login with:")
    print(f"  Email: {email}")
    print(f"  Password: {'*' * len(password)}")
    
    success = test_login(email, password)
    
    print(f"\n{'='*60}")
    if success:
        print("[OK] Login test PASSED - credentials are correct!")
        print("The login should work in the web interface.")
    else:
        print("[ERROR] Login test FAILED - check the errors above")
        print("You may need to reset the password.")
    print(f"{'='*60}\n")

