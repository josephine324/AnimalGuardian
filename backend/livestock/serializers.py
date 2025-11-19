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

class HealthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecord
        fields = '__all__'

class VaccinationRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = VaccinationRecord
        fields = '__all__'
