#!/usr/bin/env python
"""Reset password for a user"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def reset_password(email, new_password):
    print(f"\n{'='*60}")
    print(f"Resetting password for: {email}")
    print(f"{'='*60}\n")
    
    user = User.objects.filter(email=email).only('id', 'email', 'phone_number', 'username').first()
    
    if not user:
        print(f"[ERROR] No user found with email: {email}")
        return False
    
    print(f"[OK] User found: {user.username}")
    print(f"   Email: {user.email}")
    print(f"   Phone: {user.phone_number}")
    
    user.set_password(new_password)
    user.save()
    
    print(f"\n[OK] Password reset successful!")
    print(f"   New password: {new_password}")
    print(f"\nYou can now login with:")
    print(f"   Email: {email}")
    print(f"   Password: {new_password}")
    
    return True

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python reset_user_password.py <email> <new_password>")
        print("\nExample:")
        print("  python reset_user_password.py j.mutesi@alustudent.com newpassword123")
        sys.exit(1)
    
    email = sys.argv[1]
    new_password = sys.argv[2]
    
    reset_password(email, new_password)

