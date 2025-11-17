import 'dart:convert';

enum LivestockStatus {
  healthy,
  sick,
  pregnant,
  inHeat,
  deceased,
  sold,
}

enum LivestockGender {
  male,
  female,
}

extension LivestockStatusExtension on LivestockStatus {
  String get name {
    switch (this) {
      case LivestockStatus.healthy:
        return 'Healthy';
      case LivestockStatus.sick:
        return 'Sick';
      case LivestockStatus.pregnant:
        return 'Pregnant';
      case LivestockStatus.inHeat:
        return 'In Heat';
      case LivestockStatus.deceased:
        return 'Deceased';
      case LivestockStatus.sold:
        return 'Sold';
    }
  }
  
  String get apiValue {
    switch (this) {
      case LivestockStatus.healthy:
        return 'healthy';
      case LivestockStatus.sick:
        return 'sick';
      case LivestockStatus.pregnant:
        return 'pregnant';
      case LivestockStatus.inHeat:
        return 'in_heat';
      case LivestockStatus.deceased:
        return 'deceased';
      case LivestockStatus.sold:
        return 'sold';
    }
  }
  
  static LivestockStatus fromApiValue(String value) {
    switch (value) {
      case 'healthy':
        return LivestockStatus.healthy;
      case 'sick':
        return LivestockStatus.sick;
      case 'pregnant':
        return LivestockStatus.pregnant;
      case 'in_heat':
        return LivestockStatus.inHeat;
      case 'deceased':
        return LivestockStatus.deceased;
      case 'sold':
        return LivestockStatus.sold;
      default:
        return LivestockStatus.healthy;
    }
  }
}

extension LivestockGenderExtension on LivestockGender {
  String get name {
    switch (this) {
      case LivestockGender.male:
        return 'Male';
      case LivestockGender.female:
        return 'Female';
    }
  }
  
  String get apiValue {
    switch (this) {
      case LivestockGender.male:
        return 'M';
      case LivestockGender.female:
        return 'F';
    }
  }
  
  static LivestockGender fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'M':
      case 'MALE':
        return LivestockGender.male;
      case 'F':
      case 'FEMALE':
        return LivestockGender.female;
      default:
        return LivestockGender.male;
    }
  }
}

class LivestockType {
  final int id;
  final String name;
  final String? nameKinyarwanda;
  final String? nameFrench;

  const LivestockType({
    required this.id,
    required this.name,
    this.nameKinyarwanda,
    this.nameFrench,
  });

  factory LivestockType.fromMap(Map<String, dynamic> map) {
    return LivestockType(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      nameKinyarwanda: map['name_kinyarwanda'],
      nameFrench: map['name_french'],
    );
  }
}

class Breed {
  final int id;
  final int livestockTypeId;
  final String name;
  final String? nameKinyarwanda;
  final LivestockType? livestockType;

  const Breed({
    required this.id,
    required this.livestockTypeId,
    required this.name,
    this.nameKinyarwanda,
    this.livestockType,
  });

  factory Breed.fromMap(Map<String, dynamic> map) {
    return Breed(
      id: map['id'] ?? 0,
      livestockTypeId: map['livestock_type'] is int 
          ? map['livestock_type'] 
          : map['livestock_type']?['id'] ?? 0,
      name: map['name'] ?? '',
      nameKinyarwanda: map['name_kinyarwanda'],
      livestockType: map['livestock_type'] is Map 
          ? LivestockType.fromMap(map['livestock_type']) 
          : null,
    );
  }
}

class Livestock {
  final int id;
  final int ownerId;
  final int livestockTypeId;
  final int? breedId;
  final String? name;
  final String? tagNumber;
  final LivestockGender gender;
  final LivestockStatus status;
  final DateTime? birthDate;
  final double? weightKg;
  final String? color;
  final String? description;
  final DateTime? lastVaccinationDate;
  final DateTime? lastDewormingDate;
  final DateTime? lastHealthCheck;
  final bool isPregnant;
  final DateTime? pregnancyStartDate;
  final DateTime? expectedDeliveryDate;
  final double? dailyMilkProductionLiters;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related data (populated from API)
  final LivestockType? livestockType;
  final Breed? breed;

  const Livestock({
    required this.id,
    required this.ownerId,
    required this.livestockTypeId,
    this.breedId,
    this.name,
    this.tagNumber,
    required this.gender,
    required this.status,
    this.birthDate,
    this.weightKg,
    this.color,
    this.description,
    this.lastVaccinationDate,
    this.lastDewormingDate,
    this.lastHealthCheck,
    this.isPregnant = false,
    this.pregnancyStartDate,
    this.expectedDeliveryDate,
    this.dailyMilkProductionLiters,
    required this.createdAt,
    required this.updatedAt,
    this.livestockType,
    this.breed,
  });

  factory Livestock.fromMap(Map<String, dynamic> map) {
    return Livestock(
      id: map['id'] ?? 0,
      ownerId: map['owner'] is int ? map['owner'] : int.tryParse(map['owner']?.toString() ?? '0') ?? 0,
      livestockTypeId: map['livestock_type'] is int 
          ? map['livestock_type'] 
          : map['livestock_type']?['id'] ?? 0,
      breedId: map['breed'] is int 
          ? map['breed'] 
          : map['breed']?['id'],
      name: map['name'],
      tagNumber: map['tag_number'],
      gender: LivestockGenderExtension.fromApiValue(map['gender'] ?? 'M'),
      status: LivestockStatusExtension.fromApiValue(map['status'] ?? 'healthy'),
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      weightKg: map['weight_kg'] != null ? double.tryParse(map['weight_kg'].toString()) : null,
      color: map['color'],
      description: map['description'],
      lastVaccinationDate: map['last_vaccination_date'] != null 
          ? DateTime.parse(map['last_vaccination_date']) 
          : null,
      lastDewormingDate: map['last_deworming_date'] != null 
          ? DateTime.parse(map['last_deworming_date']) 
          : null,
      lastHealthCheck: map['last_health_check'] != null 
          ? DateTime.parse(map['last_health_check']) 
          : null,
      isPregnant: map['is_pregnant'] ?? false,
      pregnancyStartDate: map['pregnancy_start_date'] != null 
          ? DateTime.parse(map['pregnancy_start_date']) 
          : null,
      expectedDeliveryDate: map['expected_delivery_date'] != null 
          ? DateTime.parse(map['expected_delivery_date']) 
          : null,
      dailyMilkProductionLiters: map['daily_milk_production_liters'] != null 
          ? double.tryParse(map['daily_milk_production_liters'].toString()) 
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      livestockType: map['livestock_type'] is Map 
          ? LivestockType.fromMap(map['livestock_type']) 
          : null,
      breed: map['breed'] is Map 
          ? Breed.fromMap(map['breed']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestock_type': livestockTypeId,
      if (breedId != null) 'breed': breedId,
      if (name != null) 'name': name,
      if (tagNumber != null) 'tag_number': tagNumber,
      'gender': gender.apiValue,
      'status': status.apiValue,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T')[0],
      if (weightKg != null) 'weight_kg': weightKg,
      if (color != null) 'color': color,
      if (description != null) 'description': description,
      if (lastVaccinationDate != null) 
        'last_vaccination_date': lastVaccinationDate!.toIso8601String().split('T')[0],
      if (lastDewormingDate != null) 
        'last_deworming_date': lastDewormingDate!.toIso8601String().split('T')[0],
      if (lastHealthCheck != null) 
        'last_health_check': lastHealthCheck!.toIso8601String().split('T')[0],
      'is_pregnant': isPregnant,
      if (pregnancyStartDate != null) 
        'pregnancy_start_date': pregnancyStartDate!.toIso8601String().split('T')[0],
      if (expectedDeliveryDate != null) 
        'expected_delivery_date': expectedDeliveryDate!.toIso8601String().split('T')[0],
      if (dailyMilkProductionLiters != null) 
        'daily_milk_production_liters': dailyMilkProductionLiters,
    };
  }

  String toJson() => json.encode(toMap());
  factory Livestock.fromJson(String source) => Livestock.fromMap(json.decode(source));

  String get displayName => name ?? tagNumber ?? 'Unnamed';
  
  int? get ageMonths {
    if (birthDate == null) return null;
    final now = DateTime.now();
    return (now.year - birthDate!.year) * 12 + (now.month - birthDate!.month);
  }
}

