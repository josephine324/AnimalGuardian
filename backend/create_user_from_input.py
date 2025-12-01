#!/usr/bin/env python
"""
Interactive script to create a user with real credentials.
This allows you to use your actual registration details.
"""
import os
import sys
import django
import getpass

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
# Unset DATABASE_URL to use SQLite
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']
django.setup()

from accounts.models import User, VeterinarianProfile

def create_user_interactive():
    """Create a user interactively with real credentials."""
    
    print("\n" + "="*60)
    print("Create User with Real Credentials")
    print("="*60 + "\n")
    
    # Get user input
    print("Enter your registration details:")
    print("-" * 60)
    
    email = input("Email address: ").strip()
    if not email:
        print("Error: Email is required!")
        return None
    
    phone_number = input("Phone number (e.g., 0781234567): ").strip()
    if not phone_number:
        print("Error: Phone number is required!")
        return None
    
    first_name = input("First name: ").strip()
    last_name = input("Last name: ").strip()
    
    # Get user type
    print("\nUser type options:")
    print("  1. Sector Veterinarian (can access web dashboard)")
    print("  2. Admin (can access web dashboard)")
    print("  3. Local Veterinarian (mobile app only)")
    print("  4. Farmer (mobile app only)")
    
    user_type_choice = input("\nSelect user type (1-4) [1]: ").strip() or "1"
    
    user_type_map = {
        "1": "sector_vet",
        "2": "admin",
        "3": "local_vet",
        "4": "farmer"
    }
    
    user_type = user_type_map.get(user_type_choice, "sector_vet")
    
    # Get password securely
    password = getpass.getpass("Password: ")
    if not password:
        print("Error: Password is required!")
        return None
    
    password_confirm = getpass.getpass("Confirm password: ")
    if password != password_confirm:
        print("Error: Passwords do not match!")
        return None
    
    print("\n" + "="*60)
    print("Creating user...")
    print("="*60 + "\n")
    
    try:
        # Check if user already exists
        user = User.objects.filter(email=email).first()
        if not user:
            user = User.objects.filter(phone_number=phone_number).first()
        
        if user:
            print(f"User already exists: {user.get_full_name()} (ID: {user.id})")
            update = input("Update existing user? (y/n) [y]: ").strip().lower() or "y"
            
            if update == "y":
                print("Updating user...")
                user.email = email
                user.phone_number = phone_number
                user.first_name = first_name
                user.last_name = last_name
                user.user_type = user_type
                user.is_active = True
                
                # Auto-approve for web dashboard users
                if user_type in ['sector_vet', 'admin']:
                    user.is_approved_by_admin = True
                    user.is_staff = True
                    if user_type == 'admin':
                        user.is_superuser = True
                else:
                    user.is_approved_by_admin = True  # Auto-approve for local dev
                
                user.is_verified = True
                user.set_password(password)
                user.save()
                print(f"[OK] User updated successfully!")
            else:
                print("Cancelled. User not updated.")
                return user
        else:
            # Create new user
            username = email.split('@')[0] if email else phone_number.replace('+', '').replace('-', '').replace(' ', '')
            
            if user_type in ['admin']:
                user = User.objects.create_superuser(
                    username=username,
                    email=email,
                    phone_number=phone_number,
                    password=password,
                    first_name=first_name,
                    last_name=last_name,
                    user_type=user_type,
                    is_active=True,
                    is_approved_by_admin=True,
                    is_verified=True,
                )
            else:
                user = User.objects.create_user(
                    username=username,
                    email=email,
                    phone_number=phone_number,
                    password=password,
                    first_name=first_name,
                    last_name=last_name,
                    user_type=user_type,
                    is_active=True,
                    is_approved_by_admin=True,
                    is_verified=True,
                )
            
            if user_type in ['sector_vet', 'admin']:
                user.is_staff = True
                user.save()
            
            print(f"[OK] User created successfully!")
        
        # Create veterinarian profile if needed
        if user_type in ['sector_vet', 'local_vet']:
            vet_profile, created = VeterinarianProfile.objects.get_or_create(
                user=user,
                defaults={
                    'license_number': f'SVET-{user.id:04d}' if user_type == 'sector_vet' else f'LVET-{user.id:04d}',
                    'license_type': 'licensed',
                    'specialization': 'Administration' if user_type == 'sector_vet' else 'General Practice',
                    'is_available': user_type == 'sector_vet',
                }
            )
            if created:
                print(f"[OK] Veterinarian profile created")
        
        print("\n" + "="*60)
        print("User Details:")
        print("="*60)
        print(f"Email:    {email}")
        print(f"Phone:    {phone_number}")
        print(f"Name:     {first_name} {last_name}".strip())
        print(f"Type:     {user_type}")
        print(f"Status:   Active and Approved")
        
        if user_type in ['sector_vet', 'admin']:
            print(f"\n✓ You can now login to the web dashboard at http://localhost:3000")
            print(f"  The dashboard will show: 'Welcome back, {first_name or last_name or email.split('@')[0]}!'")
        else:
            print(f"\n✓ You can use the mobile app with these credentials")
        
        print("="*60 + "\n")
        
        return user
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    create_user_interactive()

