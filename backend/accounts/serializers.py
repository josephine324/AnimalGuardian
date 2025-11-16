from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, VeterinarianProfile, FarmerProfile

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    
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
            'password_confirm': {'write_only': True}
        }
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Passwords don't match.")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
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
