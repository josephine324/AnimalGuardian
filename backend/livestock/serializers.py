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
        required=True
    )
    breed = BreedSerializer(read_only=True)
    breed_id = serializers.PrimaryKeyRelatedField(
        queryset=Breed.objects.all(),
        source='breed',
        write_only=True,
        required=False,
        allow_null=True
    )
    
    class Meta:
        model = Livestock
        fields = [
            'id', 'livestock_type', 'livestock_type_id', 'breed', 'breed_id', 'name', 'tag_number',
            'gender', 'status', 'birth_date', 'weight_kg', 'color',
            'description', 'last_vaccination_date', 'last_deworming_date',
            'last_health_check', 'is_pregnant', 'pregnancy_start_date',
            'expected_delivery_date', 'daily_milk_production_liters',
            'created_at', 'updated_at'
        ]
    
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
        
        # Validate breed belongs to livestock_type if breed is provided
        breed = data.get('breed')
        livestock_type = data.get('livestock_type')
        
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
