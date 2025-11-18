#!/usr/bin/env python
"""Test script to debug login authentication"""
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
    user_obj = User.objects.filter(email=email).first()
    
    if not user_obj:
        print(f"❌ ERROR: No user found with email: {email}")
        print("\nAvailable users in database:")
        all_users = User.objects.all()[:10]
        for u in all_users:
            print(f"  - Email: {u.email}, Phone: {u.phone_number}, Username: {u.username}, Active: {u.is_active}")
        return False
    
    print(f"✅ User found!")
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
        print(f"\n❌ ERROR: User has no phone_number set!")
        print("   Authentication requires phone_number as USERNAME_FIELD")
        return False
    
    # Step 3: Try authentication
    print(f"\nStep 2: Attempting authentication...")
    print(f"   Using phone_number as username: {user_obj.phone_number}")
    
    user = authenticate(username=user_obj.phone_number, password=password)
    
    if user:
        print(f"✅ Authentication SUCCESSFUL!")
        print(f"   - Authenticated User ID: {user.id}")
        print(f"   - Email: {user.email}")
        return True
    else:
        print(f"❌ Authentication FAILED!")
        print(f"\nPossible reasons:")
        print(f"   1. Password is incorrect")
        print(f"   2. Password hash doesn't match")
        print(f"   3. User account is locked")
        
        # Check password manually
        print(f"\nStep 3: Checking password hash...")
        if user_obj.check_password(password):
            print(f"✅ Password check PASSED (password is correct)")
            print(f"   But authenticate() returned None - this is unusual!")
        else:
            print(f"❌ Password check FAILED (password is incorrect)")
            print(f"   The password you provided doesn't match the stored hash")
        
        return False

if __name__ == '__main__':
    # Test with the email from the error
    test_email = 'j.mutesi@alustudent.com'
    test_password = input(f"Enter password for {test_email}: ")
    
    success = test_login(test_email, test_password)
    
    if success:
        print(f"\n{'='*60}")
        print("✅ Login test PASSED - credentials are correct!")
        print(f"{'='*60}\n")
    else:
        print(f"\n{'='*60}")
        print("❌ Login test FAILED - check the errors above")
        print(f"{'='*60}\n")

