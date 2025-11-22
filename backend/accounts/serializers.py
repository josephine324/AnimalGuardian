from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.utils.text import slugify
import secrets
from .models import User, VeterinarianProfile, FarmerProfile

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=False)
    approved_by_name = serializers.SerializerMethodField()
    veterinarian_profile = serializers.SerializerMethodField()
    farmer_profile = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'phone_number', 'first_name', 'last_name', 'email',
            'gender', 'date_of_birth', 'province', 'district', 'sector',
            'cell', 'village', 'preferred_language', 'user_type',
            'is_verified', 'is_approved_by_admin', 'approved_by', 'approved_at',
            'approval_notes', 'approved_by_name',
            'password', 'password_confirm', 'created_at', 'updated_at',
            'veterinarian_profile', 'farmer_profile'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'password_confirm': {'write_only': True},
            'username': {'required': False},  # Auto-generated if not provided
            'email': {'required': False},  # Email is optional
            'approved_by': {'read_only': True},
            'approved_at': {'read_only': True},
        }
    
    def get_approved_by_name(self, obj):
        try:
            if obj and obj.approved_by:
                return obj.approved_by.get_full_name() or obj.approved_by.username
        except Exception:
            # If there's any error accessing approved_by, return None
            pass
        return None
    
    def get_veterinarian_profile(self, obj):
        """Get veterinarian profile if user is a vet."""
        try:
            if hasattr(obj, 'vet_profile'):
                profile = obj.vet_profile
                return {
                    'id': profile.id,
                    'license_number': profile.license_number,
                    'license_type': profile.license_type,
                    'specialization': profile.specialization,
                    'clinic_name': profile.clinic_name,
                    'clinic_address': profile.clinic_address,
                    'is_available': profile.is_available,
                    'working_hours': profile.working_hours,
                    'years_of_experience': profile.years_of_experience,
                    'rating': str(profile.rating),
                    'total_cases_handled': profile.total_cases_handled,
                }
        except VeterinarianProfile.DoesNotExist:
            pass
        return None
    
    def get_farmer_profile(self, obj):
        """Get farmer profile if user is a farmer."""
        try:
            if hasattr(obj, 'farmer_profile'):
                profile = obj.farmer_profile
                return {
                    'id': profile.id,
                    'farm_name': profile.farm_name or '',
                    'farm_size': str(profile.farm_size) if profile.farm_size is not None else None,
                    'farm_size_unit': profile.farm_size_unit or 'hectares',
                    'total_livestock_count': profile.total_livestock_count or 0,
                    'years_of_farming': profile.years_of_farming or 0,
                    'has_smartphone': profile.has_smartphone if hasattr(profile, 'has_smartphone') else False,
                    'has_basic_phone': profile.has_basic_phone if hasattr(profile, 'has_basic_phone') else True,
                    'has_internet_access': profile.has_internet_access if hasattr(profile, 'has_internet_access') else False,
                    'preferred_communication': profile.preferred_communication or 'sms',
                }
        except (FarmerProfile.DoesNotExist, AttributeError, Exception) as e:
            # Silently return None if profile doesn't exist or has issues
            pass
        return None
    
    def validate(self, attrs):
        # Only validate password on create
        if self.instance is None:
            # Clean and validate phone number
            phone_number = attrs.get('phone_number')
            user_type = attrs.get('user_type', 'farmer')
            
            if phone_number:
                # Remove spaces, dashes, and other non-digit characters
                import re
                cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                
                # Remove country code if present (+250 or 250)
                if cleaned_phone.startswith('250') and len(cleaned_phone) > 10:
                    cleaned_phone = cleaned_phone[3:]  # Remove '250' prefix
                
                # More flexible validation for sector vets and admins
                if user_type in ['sector_vet', 'admin']:
                    # Sector vets can have more flexible phone numbers
                    # Just ensure it's between 8-15 digits (international format)
                    if not (8 <= len(cleaned_phone) <= 15):
                        raise serializers.ValidationError({
                            'phone_number': 'Phone number must be between 8 and 15 digits. For Rwanda, use format: 0781234567'
                        })
                else:
                    # For farmers and local vets, validate Rwanda format strictly
                    if not re.match(r'^(078|079|073|072)\d{7}$', cleaned_phone):
                        raise serializers.ValidationError({
                            'phone_number': 'Phone number must start with 078, 079, 073, or 072 and be exactly 10 digits (e.g., 0781234567)'
                        })
                
                attrs['phone_number'] = cleaned_phone
                
                # Check for duplicate phone number
                if User.objects.filter(phone_number=cleaned_phone).exists():
                    raise serializers.ValidationError({
                        'phone_number': 'An account with this phone number already exists. Please use a different phone number or try logging in.'
                    })
            
            # Handle email - only validate if email is actually provided and not empty
            # Skip entirely if email is not in attrs
            if 'email' in attrs:
                email = attrs.get('email')
                if email is not None:
                    email_str = str(email).strip() if email else ''
                    if email_str:
                        # Validate email format if provided
                        import re
                        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                        if not re.match(email_pattern, email_str):
                            raise serializers.ValidationError({
                                'email': 'Please enter a valid email address.'
                            })
                        attrs['email'] = email_str
                        # Check for duplicate email only if email is provided and valid
                        if User.objects.filter(email=email_str).exists():
                            raise serializers.ValidationError({
                                'email': 'An account with this email address already exists. Please use a different email or try logging in.'
                            })
                    else:
                        # Convert empty string to None - no validation needed
                        attrs['email'] = None
                else:
                    # Email is None, remove it from attrs
                    attrs.pop('email', None)
            
            # Check for duplicate username (if provided)
            username = attrs.get('username')
            if username:
                if User.objects.filter(username=username).exists():
                    raise serializers.ValidationError({
                        'username': 'An account with this username already exists. Please use a different username.'
                    })
            
            if 'password' not in attrs:
                raise serializers.ValidationError({
                    'password': 'Password is required.'
                })
            
            # Validate password strength
            password = attrs.get('password')
            if password:
                if len(password) < 8:
                    raise serializers.ValidationError({
                        'password': 'Password must be at least 8 characters long.'
                    })
                if not any(c.isdigit() for c in password):
                    raise serializers.ValidationError({
                        'password': 'Password must contain at least one number.'
                    })
                if not any(c.isalpha() for c in password):
                    raise serializers.ValidationError({
                        'password': 'Password must contain at least one letter.'
                    })
            
            # Auto-fill password_confirm from password if not provided (for admin-created users)
            if 'password_confirm' not in attrs:
                attrs['password_confirm'] = attrs['password']
            if attrs['password'] != attrs['password_confirm']:
                raise serializers.ValidationError({
                    'password_confirm': "Passwords don't match."
                })
            
        elif 'password' in attrs or 'password_confirm' in attrs:
            # Update password
            if 'password' not in attrs:
                raise serializers.ValidationError("Password is required to change password.")
            # Auto-fill password_confirm from password if not provided
            if 'password_confirm' not in attrs:
                attrs['password_confirm'] = attrs['password']
            if attrs['password'] != attrs['password_confirm']:
                raise serializers.ValidationError("Passwords don't match.")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm', None)
        password = validated_data.pop('password')
        
        # Handle email - convert empty string to None (CRITICAL: prevents unique constraint violation)
        # SQLite treats empty string as a value, so multiple empty strings violate unique constraint
        if 'email' in validated_data:
            email = validated_data.get('email')
            if email is None or email == '' or (isinstance(email, str) and not email.strip()):
                # Explicitly set to None - don't pass empty string
                validated_data['email'] = None
            else:
                # Ensure email is properly trimmed
                validated_data['email'] = email.strip() if isinstance(email, str) else email
        else:
            # If email is not in validated_data, explicitly set to None
            validated_data['email'] = None
        
        # Generate username if not provided
        if 'username' not in validated_data or not validated_data.get('username'):
            email = validated_data.get('email') or ''
            phone_number = validated_data.get('phone_number', '')
            
            if email:
                username_input = email.split('@')[0]
            elif phone_number:
                username_input = phone_number.replace('+', '').replace('-', '').replace(' ', '')
            else:
                username_input = 'user'
            
            base_username = slugify(username_input) or 'user'
            candidate_username = base_username
            # Ensure username is unique
            while User.objects.filter(username=candidate_username).exists():
                candidate_username = f"{base_username}-{secrets.token_hex(3)}"
            validated_data['username'] = candidate_username
        
        # Set default values for optional fields
        validated_data.setdefault('preferred_language', 'en')
        
        # Create user - email will be None if not provided
        user = User.objects.create_user(password=password, **validated_data)
        
        # Double-check: ensure email is None if it was empty (safety check)
        if user.email == '':
            user.email = None
            user.save(update_fields=['email'])
        
        # Automatically create VeterinarianProfile if user is a veterinarian
        user_type = validated_data.get('user_type')
        if user_type in ['local_vet', 'sector_vet']:
            # Generate a unique license number
            license_number = f'VET-{user.id}-{secrets.token_hex(4).upper()}'
            while VeterinarianProfile.objects.filter(license_number=license_number).exists():
                license_number = f'VET-{user.id}-{secrets.token_hex(4).upper()}'
            
            VeterinarianProfile.objects.create(
                user=user,
                license_number=license_number,
                license_type='licensed',
                specialization=validated_data.get('specialization', 'General Practice'),
                is_available=False  # Start as offline - vet must set themselves to online via app
            )
        
        # Automatically create FarmerProfile if user is a farmer
        elif user_type == 'farmer':
            FarmerProfile.objects.create(user=user)
        
        return user
    
    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        validated_data.pop('password_confirm', None)
        
        # Clean and validate phone number if being updated
        if 'phone_number' in validated_data:
            import re
            phone_number = validated_data['phone_number']
            user_type = instance.user_type if hasattr(instance, 'user_type') else 'farmer'
            
            if phone_number:
                cleaned_phone = re.sub(r'[^\d]', '', str(phone_number))
                
                # Remove country code if present (+250 or 250)
                if cleaned_phone.startswith('250') and len(cleaned_phone) > 10:
                    cleaned_phone = cleaned_phone[3:]  # Remove '250' prefix
                
                # More flexible validation for sector vets and admins
                if user_type in ['sector_vet', 'admin']:
                    # Sector vets can have more flexible phone numbers
                    if not (8 <= len(cleaned_phone) <= 15):
                        raise serializers.ValidationError({
                            'phone_number': 'Phone number must be between 8 and 15 digits. For Rwanda, use format: 0781234567'
                        })
                else:
                    # For farmers and local vets, validate Rwanda format strictly
                    if not re.match(r'^(078|079|073|072)\d{7}$', cleaned_phone):
                        raise serializers.ValidationError({
                            'phone_number': 'Phone number must start with 078, 079, 073, or 072 and be exactly 10 digits (e.g., 0781234567)'
                        })
                
                validated_data['phone_number'] = cleaned_phone
        
        if password:
            instance.set_password(password)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance

class SimpleUserSerializer(serializers.ModelSerializer):
    """Simplified UserSerializer without nested profiles to avoid circular references."""
    approved_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'phone_number', 'first_name', 'last_name', 'email',
            'gender', 'date_of_birth', 'province', 'district', 'sector',
            'cell', 'village', 'preferred_language', 'user_type',
            'is_verified', 'is_approved_by_admin', 'approved_by', 'approved_at',
            'approval_notes', 'approved_by_name',
            'created_at', 'updated_at'
        ]
        extra_kwargs = {
            'approved_by': {'read_only': True},
            'approved_at': {'read_only': True},
        }
    
    def get_approved_by_name(self, obj):
        try:
            if obj and obj.approved_by:
                return obj.approved_by.get_full_name() or obj.approved_by.username
        except Exception:
            pass
        return None


class FarmerProfileSerializer(serializers.ModelSerializer):
    user = SimpleUserSerializer(read_only=True)
    
    class Meta:
        model = FarmerProfile
        fields = [
            'id', 'user', 'farm_name', 'farm_size', 'farm_size_unit',
            'total_livestock_count', 'years_of_farming', 'has_smartphone',
            'has_basic_phone', 'has_internet_access', 'preferred_communication',
            'created_at', 'updated_at'
        ]

class VeterinarianProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = VeterinarianProfile
        fields = [
            'id', 'user', 'license_number', 'license_type', 'specialization',
            'clinic_name', 'clinic_address', 'is_available', 'working_hours',
            'years_of_experience', 'rating', 'total_cases_handled',
            'created_at', 'updated_at'
        ]
