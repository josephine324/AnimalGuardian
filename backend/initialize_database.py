#!/usr/bin/env python3
"""
Initialize database with seed data for AnimalGuardian
Creates livestock types, breeds, diseases, and other essential data
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(__file__))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from livestock.models import LivestockType, Breed
from cases.models import Disease
from marketplace.models import Category
from accounts.models import User

def create_livestock_types():
    """Create livestock types"""
    types_data = [
        {'name': 'Cattle', 'name_kinyarwanda': 'Inka', 'name_french': 'Bovin', 'average_lifespan_years': 20, 'gestation_period_days': 280},
        {'name': 'Goat', 'name_kinyarwanda': 'Ihene', 'name_french': 'Chèvre', 'average_lifespan_years': 15, 'gestation_period_days': 150},
        {'name': 'Sheep', 'name_kinyarwanda': 'Intama', 'name_french': 'Mouton', 'average_lifespan_years': 12, 'gestation_period_days': 150},
        {'name': 'Pig', 'name_kinyarwanda': 'Ingurube', 'name_french': 'Cochon', 'average_lifespan_years': 15, 'gestation_period_days': 114},
        {'name': 'Chicken', 'name_kinyarwanda': 'Inkoko', 'name_french': 'Poulet', 'average_lifespan_years': 8, 'gestation_period_days': 21},
        {'name': 'Rabbit', 'name_kinyarwanda': 'Urukwavu', 'name_french': 'Lapin', 'average_lifespan_years': 8, 'gestation_period_days': 30},
    ]
    
    created = 0
    for type_data in types_data:
        obj, created_flag = LivestockType.objects.get_or_create(
            name=type_data['name'],
            defaults=type_data
        )
        if created_flag:
            created += 1
            print(f"  Created livestock type: {type_data['name']}")
    
    print(f"[OK] Created {created} livestock types")
    return created

def create_breeds():
    """Create breeds for each livestock type"""
    breeds_data = {
        'Cattle': [
            {'name': 'Ankole', 'name_kinyarwanda': 'Ankole', 'origin': 'Rwanda', 'characteristics': 'Long horns, hardy'},
            {'name': 'Holstein', 'name_kinyarwanda': 'Holstein', 'origin': 'Europe', 'characteristics': 'High milk production'},
            {'name': 'Friesian', 'name_kinyarwanda': 'Friesian', 'origin': 'Europe', 'characteristics': 'Dairy breed'},
        ],
        'Goat': [
            {'name': 'Boer', 'name_kinyarwanda': 'Boer', 'origin': 'South Africa', 'characteristics': 'Meat breed'},
            {'name': 'Alpine', 'name_kinyarwanda': 'Alpine', 'origin': 'Europe', 'characteristics': 'Dairy breed'},
            {'name': 'Local', 'name_kinyarwanda': 'Ihene z\'Abanyarwanda', 'origin': 'Rwanda', 'characteristics': 'Hardy, adapted to local conditions'},
        ],
        'Sheep': [
            {'name': 'Dorper', 'name_kinyarwanda': 'Dorper', 'origin': 'South Africa', 'characteristics': 'Meat breed'},
            {'name': 'Local', 'name_kinyarwanda': 'Intama z\'Abanyarwanda', 'origin': 'Rwanda', 'characteristics': 'Hardy'},
        ],
        'Pig': [
            {'name': 'Large White', 'name_kinyarwanda': 'Large White', 'origin': 'Europe', 'characteristics': 'Meat breed'},
            {'name': 'Landrace', 'name_kinyarwanda': 'Landrace', 'origin': 'Europe', 'characteristics': 'Bacon breed'},
            {'name': 'Local', 'name_kinyarwanda': 'Ingurube z\'Abanyarwanda', 'origin': 'Rwanda', 'characteristics': 'Hardy'},
        ],
        'Chicken': [
            {'name': 'Broiler', 'name_kinyarwanda': 'Broiler', 'origin': 'Commercial', 'characteristics': 'Meat production'},
            {'name': 'Layer', 'name_kinyarwanda': 'Layer', 'origin': 'Commercial', 'characteristics': 'Egg production'},
            {'name': 'Local', 'name_kinyarwanda': 'Inkoko z\'Abanyarwanda', 'origin': 'Rwanda', 'characteristics': 'Dual purpose'},
        ],
        'Rabbit': [
            {'name': 'New Zealand White', 'name_kinyarwanda': 'New Zealand White', 'origin': 'New Zealand', 'characteristics': 'Meat breed'},
            {'name': 'Local', 'name_kinyarwanda': 'Urukwavu rw\'Abanyarwanda', 'origin': 'Rwanda', 'characteristics': 'Hardy'},
        ],
    }
    
    created = 0
    for type_name, breeds in breeds_data.items():
        try:
            livestock_type = LivestockType.objects.get(name=type_name)
            for breed_data in breeds:
                obj, created_flag = Breed.objects.get_or_create(
                    name=breed_data['name'],
                    livestock_type=livestock_type,
                    defaults=breed_data
                )
                if created_flag:
                    created += 1
                    print(f"  Created breed: {breed_data['name']} ({type_name})")
        except LivestockType.DoesNotExist:
            print(f"  [WARN] Livestock type '{type_name}' not found, skipping breeds")
    
    print(f"[OK] Created {created} breeds")
    return created

def create_diseases():
    """Create common diseases"""
    diseases_data = [
        {
            'name': 'Foot and Mouth Disease',
            'name_kinyarwanda': 'Indwara y\'Amaguru n\'Amunwa',
            'name_french': 'Fièvre aphteuse',
            'common_symptoms': 'Fever, blisters in mouth and feet, lameness, loss of appetite',
            'treatment_guidelines': 'Vaccination, isolation, supportive care',
            'prevention_measures': 'Regular vaccination, biosecurity measures',
            'severity': 'high',
            'is_contagious': True,
            'is_zoonotic': False,
            'affected_species': ['Cattle', 'Goat', 'Sheep', 'Pig']
        },
        {
            'name': 'East Coast Fever',
            'name_kinyarwanda': 'Indwara y\'Uburasirazuba',
            'name_french': 'Fièvre de la côte est',
            'common_symptoms': 'Fever, enlarged lymph nodes, difficulty breathing, loss of appetite',
            'treatment_guidelines': 'Antibiotics, supportive care',
            'prevention_measures': 'Tick control, vaccination',
            'severity': 'high',
            'is_contagious': False,
            'is_zoonotic': False,
            'affected_species': ['Cattle']
        },
        {
            'name': 'Newcastle Disease',
            'name_kinyarwanda': 'Indwara ya Newcastle',
            'name_french': 'Maladie de Newcastle',
            'common_symptoms': 'Respiratory distress, nervous signs, drop in egg production',
            'treatment_guidelines': 'No specific treatment, supportive care',
            'prevention_measures': 'Vaccination, biosecurity',
            'severity': 'high',
            'is_contagious': True,
            'is_zoonotic': False,
            'affected_species': ['Chicken']
        },
        {
            'name': 'Mastitis',
            'name_kinyarwanda': 'Mastitis',
            'name_french': 'Mastite',
            'common_symptoms': 'Swollen udder, abnormal milk, reduced milk production',
            'treatment_guidelines': 'Antibiotics, anti-inflammatory drugs',
            'prevention_measures': 'Proper milking hygiene, clean environment',
            'severity': 'medium',
            'is_contagious': False,
            'is_zoonotic': False,
            'affected_species': ['Cattle', 'Goat']
        },
        {
            'name': 'Worms (Helminthiasis)',
            'name_kinyarwanda': 'Imbwa',
            'name_french': 'Vers (Helminthiase)',
            'common_symptoms': 'Weight loss, diarrhea, anemia, poor growth',
            'treatment_guidelines': 'Deworming medication',
            'prevention_measures': 'Regular deworming, pasture management',
            'severity': 'medium',
            'is_contagious': False,
            'is_zoonotic': False,
            'affected_species': ['Cattle', 'Goat', 'Sheep', 'Pig', 'Chicken']
        },
        {
            'name': 'Anthrax',
            'name_kinyarwanda': 'Anthrax',
            'name_french': 'Charbon',
            'common_symptoms': 'Sudden death, fever, difficulty breathing, bleeding',
            'treatment_guidelines': 'Antibiotics (early stage)',
            'prevention_measures': 'Vaccination, proper disposal of carcasses',
            'severity': 'high',
            'is_contagious': True,
            'is_zoonotic': True,
            'affected_species': ['Cattle', 'Goat', 'Sheep', 'Pig']
        },
    ]
    
    created = 0
    for disease_data in diseases_data:
        affected_species = disease_data.pop('affected_species', [])
        obj, created_flag = Disease.objects.get_or_create(
            name=disease_data['name'],
            defaults=disease_data
        )
        if created_flag:
            # Add affected livestock types
            for species_name in affected_species:
                try:
                    livestock_type = LivestockType.objects.get(name=species_name)
                    obj.affected_livestock_types.add(livestock_type)
                except LivestockType.DoesNotExist:
                    pass
            created += 1
            print(f"  Created disease: {disease_data['name']}")
    
    print(f"[OK] Created {created} diseases")
    return created

def create_marketplace_categories():
    """Create marketplace categories"""
    categories_data = [
        {'name': 'Livestock Feed', 'name_kinyarwanda': 'Ibiribwa by\'Amatungo', 'description': 'Animal feed and supplements', 'icon': '🌾'},
        {'name': 'Veterinary Supplies', 'name_kinyarwanda': 'Ibikoresho by\'Abaganga', 'description': 'Veterinary medicines and equipment', 'icon': '💉'},
        {'name': 'Livestock', 'name_kinyarwanda': 'Amatungo', 'description': 'Live animals for sale', 'icon': '🐄'},
        {'name': 'Farm Equipment', 'name_kinyarwanda': 'Ibikoresho by\'Ubuhinzi', 'description': 'Farming tools and equipment', 'icon': '🔧'},
        {'name': 'Seeds & Plants', 'name_kinyarwanda': 'Imbuto n\'Ibimera', 'description': 'Crop seeds and seedlings', 'icon': '🌱'},
        {'name': 'Fertilizers', 'name_kinyarwanda': 'Ifumbire', 'description': 'Fertilizers and soil amendments', 'icon': '🌿'},
    ]
    
    created = 0
    for cat_data in categories_data:
        obj, created_flag = Category.objects.get_or_create(
            name=cat_data['name'],
            defaults=cat_data
        )
        if created_flag:
            created += 1
            print(f"  Created category: {cat_data['name']}")
    
    print(f"[OK] Created {created} marketplace categories")
    return created

def initialize_database():
    """Initialize database with all seed data"""
    print("="*60)
    print("Initializing AnimalGuardian Database")
    print("="*60)
    print()
    
    total_created = 0
    
    print("1. Creating Livestock Types...")
    total_created += create_livestock_types()
    print()
    
    print("2. Creating Breeds...")
    total_created += create_breeds()
    print()
    
    print("3. Creating Diseases...")
    total_created += create_diseases()
    print()
    
    print("4. Creating Marketplace Categories...")
    total_created += create_marketplace_categories()
    print()
    
    print("="*60)
    print(f"[OK] Database initialization complete!")
    print(f"   Total items created: {total_created}")
    print("="*60)

if __name__ == "__main__":
    initialize_database()

