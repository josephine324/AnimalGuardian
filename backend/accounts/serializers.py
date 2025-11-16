from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, VeterinarianProfile, FarmerProfile

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=False)
    approved_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'phone_number', 'first_name', 'last_name', 'email',
            'gender', 'date_of_birth', 'province', 'district', 'sector',
            'cell', 'village', 'preferred_language', 'user_type',
            'is_verified', 'is_approved_by_admin', 'approved_by', 'approved_at',
            'approval_notes', 'approved_by_name',
            'password', 'password_confirm', 'created_at', 'updated_at'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'password_confirm': {'write_only': True},
            'approved_by': {'read_only': True},
            'approved_at': {'read_only': True},
        }
    
    def get_approved_by_name(self, obj):
        if obj.approved_by:
            return obj.approved_by.get_full_name() or obj.approved_by.username
        return None
    
    def validate(self, attrs):
        # Only validate password on create
        if self.instance is None:
            if 'password' not in attrs or 'password_confirm' not in attrs:
                raise serializers.ValidationError("Password and password confirmation are required.")
            if attrs['password'] != attrs['password_confirm']:
                raise serializers.ValidationError("Passwords don't match.")
        elif 'password' in attrs or 'password_confirm' in attrs:
            # Update password
            if 'password' not in attrs or 'password_confirm' not in attrs:
                raise serializers.ValidationError("Both password and password confirmation are required to change password.")
            if attrs['password'] != attrs['password_confirm']:
                raise serializers.ValidationError("Passwords don't match.")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm', None)
        password = validated_data.pop('password')
        user = User.objects.create_user(password=password, **validated_data)
        return user
    
    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        validated_data.pop('password_confirm', None)
        
        if password:
            instance.set_password(password)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance

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
