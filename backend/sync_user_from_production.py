#!/usr/bin/env python
"""
Sync user from production/deployed database to local database.
This allows you to use your real production credentials locally.
"""
import os
import sys
import django
import requests

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
# Unset DATABASE_URL to use SQLite
if 'DATABASE_URL' in os.environ:
    del os.environ['DATABASE_URL']
django.setup()

from accounts.models import User, VeterinarianProfile

def sync_user_from_production(production_api_url, email, password):
    """
    Fetch user data from production API and create it locally.
    
    Args:
        production_api_url: Base URL of production API (e.g., https://animalguardian.onrender.com/api)
        email: User's email
        password: User's password (for local use)
    """
    
    print("\n" + "="*60)
    print("Syncing User from Production")
    print("="*60 + "\n")
    
    try:
        # Step 1: Login to production to get user data
        print(f"Step 1: Logging into production API...")
        print(f"Production URL: {production_api_url}")
        
        login_url = f"{production_api_url}/auth/login/"
        
        login_data = {
            'email': email,
            'password': password  # User provides their production password
        }
        
        response = requests.post(login_url, json=login_data, timeout=10)
        
        if response.status_code != 200:
            print(f"❌ Failed to login to production: {response.status_code}")
            print(f"Response: {response.text}")
            print("\nAlternative: You can manually enter your details or register locally.")
            return None
        
        data = response.json()
        production_user = data.get('user', {})
        
        if not production_user:
            print("❌ No user data returned from production")
            return None
        
        print("✅ Successfully retrieved user data from production\n")
        
        # Step 2: Create/update user locally
        print("Step 2: Creating/updating user in local database...")
        
        local_user = User.objects.filter(email=email).first()
        if not local_user:
            local_user = User.objects.filter(phone_number=production_user.get('phone_number')).first()
        
        user_data = {
            'email': production_user.get('email') or email,
            'phone_number': production_user.get('phone_number'),
            'first_name': production_user.get('first_name', ''),
            'last_name': production_user.get('last_name', ''),
            'user_type': production_user.get('user_type', 'farmer'),
            'is_active': True,
            'is_verified': True,
            'is_approved_by_admin': True,  # Auto-approve for local dev
        }
        
        if local_user:
            print(f"   Found existing local user: {local_user.get_full_name()}")
            print("   Updating with production data...")
            for key, value in user_data.items():
                if key != 'phone_number' or not local_user.phone_number:
                    setattr(local_user, key, value)
            local_user.set_password(password)  # Use provided password
            local_user.save()
            print("   ✅ User updated")
        else:
            print("   Creating new user...")
            username = production_user.get('username') or email.split('@')[0]
            local_user = User.objects.create_user(
                username=username,
                password=password,
                **user_data
            )
            print("   ✅ User created")
        
        # Step 3: Create veterinarian profile if needed
        if production_user.get('user_type') in ['sector_vet', 'local_vet']:
            vet_profile, created = VeterinarianProfile.objects.get_or_create(
                user=local_user,
                defaults={
                    'license_number': f'SVET-{local_user.id:04d}' if production_user.get('user_type') == 'sector_vet' else f'LVET-{local_user.id:04d}',
                    'license_type': 'licensed',
                    'specialization': production_user.get('veterinarian_profile', {}).get('specialization', 'General Practice'),
                    'is_available': production_user.get('user_type') == 'sector_vet',
                }
            )
            if created:
                print("   ✅ Veterinarian profile created")
        
        # Step 4: Summary
        print("\n" + "="*60)
        print("✅ User Synced Successfully!")
        print("="*60)
        print(f"Email:    {local_user.email}")
        print(f"Name:     {local_user.get_full_name()}")
        print(f"Type:     {local_user.user_type}")
        print(f"\nYou can now login locally with:")
        print(f"  Email:    {email}")
        print(f"  Password: {password}")
        print(f"\nThe dashboard will show: 'Welcome back, {local_user.get_full_name() or local_user.email.split('@')[0]}!'")
        print("="*60 + "\n")
        
        return local_user
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Error connecting to production API: {e}")
        print("\nAlternative: You can manually create your user locally.")
        print("Run: python create_user_from_input.py")
        return None
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Sync user from production to local database')
    parser.add_argument('--email', required=True, help='Your email address')
    parser.add_argument('--password', required=True, help='Your password')
    parser.add_argument('--production-url', default='https://animalguardian.onrender.com/api', 
                       help='Production API URL')
    
    args = parser.parse_args()
    
    sync_user_from_production(
        production_api_url=args.production_url,
        email=args.email,
        password=args.password
    )

