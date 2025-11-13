import secrets

from django.contrib.auth.password_validation import validate_password
from django.utils.text import slugify
from rest_framework import serializers

from .models import User, VeterinarianProfile, FarmerProfile

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'phone_number', 'first_name', 'last_name', 'email',
            'gender', 'date_of_birth', 'province', 'district', 'sector',
            'cell', 'village', 'preferred_language', 'user_type',
            'password', 'password_confirm'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'password_confirm': {'write_only': True},
            'username': {'required': False, 'allow_blank': True},
            'province': {'required': False, 'allow_blank': True},
            'district': {'required': False, 'allow_blank': True},
            'sector': {'required': False, 'allow_blank': True},
            'cell': {'required': False, 'allow_blank': True},
            'village': {'required': False, 'allow_blank': True},
            'preferred_language': {'required': False, 'allow_blank': True},
            'user_type': {'required': False, 'allow_blank': True},
        }
    
    def validate(self, attrs):
        password = attrs.get('password')
        password_confirm = attrs.get('password_confirm') or password
        
        if password != password_confirm:
            raise serializers.ValidationError("Passwords don't match.")
        
        attrs['password_confirm'] = password_confirm
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm', None)
        password = validated_data.pop('password')
        
        phone_number = validated_data.get('phone_number')
        email = validated_data.get('email')
        
        if phone_number and User.objects.filter(phone_number=phone_number).exists():
            raise serializers.ValidationError({'phone_number': 'User with this phone number already exists.'})
        
        username_input = validated_data.get('username')
        if not username_input:
            if email:
                username_input = email.split('@')[0]
            elif phone_number:
                username_input = phone_number
            else:
                username_input = 'user'
        
        base_username = slugify(username_input) or 'user'
        candidate_username = base_username
        while User.objects.filter(username=candidate_username).exists():
            candidate_username = f"{base_username}-{secrets.token_hex(3)}"
        validated_data['username'] = candidate_username
        
        validated_data.setdefault('user_type', 'veterinarian')
        validated_data.setdefault('province', '')
        validated_data.setdefault('district', '')
        validated_data.setdefault('sector', '')
        validated_data.setdefault('cell', '')
        validated_data.setdefault('village', '')
        validated_data.setdefault('preferred_language', 'en')
        
        user = User.objects.create_user(password=password, **validated_data)
        return user

class FarmerProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
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
