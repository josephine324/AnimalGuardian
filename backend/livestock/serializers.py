from rest_framework import serializers
from .models import Livestock, LivestockType, Breed, HealthRecord, VaccinationRecord

class LivestockTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = LivestockType
        fields = '__all__'

class BreedSerializer(serializers.ModelSerializer):
    livestock_type = LivestockTypeSerializer(read_only=True)
    
    class Meta:
        model = Breed
        fields = '__all__'

class LivestockSerializer(serializers.ModelSerializer):
    livestock_type = LivestockTypeSerializer(read_only=True)
    livestock_type_id = serializers.PrimaryKeyRelatedField(
        queryset=LivestockType.objects.all(),
        source='livestock_type',
        write_only=True,
        required=False,
        allow_null=True
    )
    livestock_type_name = serializers.CharField(
        write_only=True,
        required=False,
        allow_null=True,
        allow_blank=True,
        help_text="Name of livestock type (e.g., 'Cattle', 'Goat'). Will create if doesn't exist."
    )
    breed = BreedSerializer(read_only=True)
    breed_id = serializers.PrimaryKeyRelatedField(
        queryset=Breed.objects.all(),
        source='breed',
        write_only=True,
        required=False,
        allow_null=True
    )
    breed_name = serializers.CharField(
        write_only=True,
        required=False,
        allow_null=True,
        allow_blank=True,
        help_text="Name of breed (e.g., 'Holstein', 'Ankole'). Will create if doesn't exist."
    )
    # Add owner information for dashboard display
    owner_name = serializers.SerializerMethodField()
    owner_phone = serializers.SerializerMethodField()
    owner_sector = serializers.SerializerMethodField()
    owner_district = serializers.SerializerMethodField()
    
    class Meta:
        model = Livestock
        fields = [
            'id', 'owner', 'owner_name', 'owner_phone', 'owner_sector', 'owner_district',
            'livestock_type', 'livestock_type_id', 'livestock_type_name', 'breed', 'breed_id', 'breed_name',
            'name', 'tag_number', 'gender', 'status', 'birth_date', 'weight_kg', 'color',
            'description', 'last_vaccination_date', 'last_deworming_date',
            'last_health_check', 'is_pregnant', 'pregnancy_start_date',
            'expected_delivery_date', 'daily_milk_production_liters',
            'created_at', 'updated_at'
        ]
        read_only_fields = ('owner', 'owner_name', 'owner_phone', 'owner_sector', 'owner_district')
    
    def get_owner_name(self, obj):
        return obj.owner.get_full_name() or obj.owner.username if obj.owner else None
    
    def get_owner_phone(self, obj):
        return obj.owner.phone_number if obj.owner else None
    
    def get_owner_sector(self, obj):
        return obj.owner.sector if obj.owner else None
    
    def get_owner_district(self, obj):
        return obj.owner.district if obj.owner else None
    
    def validate_tag_number(self, value):
        """Convert empty string to None to avoid unique constraint violations."""
        if value is None:
            return None
        if isinstance(value, str):
            value = value.strip()
            if not value:
                return None
            return value
        return value
    
    def validate(self, data):
        """Additional validation."""
        # Ensure tag_number is None if empty (double-check)
        if 'tag_number' in data:
            tag_number = data['tag_number']
            if tag_number is not None and isinstance(tag_number, str) and not tag_number.strip():
                data['tag_number'] = None
        
        # Handle livestock_type_name - create or get livestock type
        livestock_type_name = data.pop('livestock_type_name', None)
        if livestock_type_name and isinstance(livestock_type_name, str) and livestock_type_name.strip():
            livestock_type, created = LivestockType.objects.get_or_create(
                name=livestock_type_name.strip()
            )
            data['livestock_type'] = livestock_type
        elif not data.get('livestock_type') and not data.get('livestock_type_id'):
            raise serializers.ValidationError({
                'livestock_type_name': 'Livestock type is required. Please provide either livestock_type_id or livestock_type_name.'
            })
        
        # Handle breed_name - create or get breed if livestock_type is available
        breed_name = data.pop('breed_name', None)
        livestock_type = data.get('livestock_type')
        if not livestock_type and 'livestock_type_id' in data:
            livestock_type = data.get('livestock_type_id')
        
        if breed_name and isinstance(breed_name, str) and breed_name.strip() and livestock_type:
            breed, created = Breed.objects.get_or_create(
                name=breed_name.strip(),
                livestock_type=livestock_type,
                defaults={'characteristics': ''}
            )
            data['breed'] = breed
        
        # Validate breed belongs to livestock_type if breed is provided
        breed = data.get('breed')
        if breed is not None and livestock_type is not None:
            if breed.livestock_type != livestock_type:
                raise serializers.ValidationError({
                    'breed_id': 'The selected breed does not belong to the selected livestock type.'
                })
        return data
    
    def create(self, validated_data):
        """Override create to ensure tag_number is None if empty."""
        # Final check: ensure tag_number is None if empty
        if 'tag_number' in validated_data:
            tag_number = validated_data['tag_number']
            if tag_number is not None and isinstance(tag_number, str) and not tag_number.strip():
                validated_data['tag_number'] = None
        
        return super().create(validated_data)

class HealthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecord
        fields = '__all__'

class VaccinationRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = VaccinationRecord
        fields = '__all__'
