import 'dart:convert';

enum CaseStatus {
  pending,
  underReview,
  investigation,
  diagnosed,
  treated,
  resolved,
  rejected,
  escalated,
}

enum CaseUrgency {
  low,
  medium,
  high,
  urgent,
}

extension CaseStatusExtension on CaseStatus {
  String get name {
    switch (this) {
      case CaseStatus.pending:
        return 'Pending Review';
      case CaseStatus.underReview:
        return 'Under Review';
      case CaseStatus.investigation:
        return 'Under Investigation';
      case CaseStatus.diagnosed:
        return 'Diagnosed';
      case CaseStatus.treated:
        return 'Treated';
      case CaseStatus.resolved:
        return 'Resolved';
      case CaseStatus.rejected:
        return 'Rejected';
      case CaseStatus.escalated:
        return 'Escalated';
    }
  }
  
  String get apiValue {
    switch (this) {
      case CaseStatus.pending:
        return 'pending';
      case CaseStatus.underReview:
        return 'under_review';
      case CaseStatus.investigation:
        return 'investigation';
      case CaseStatus.diagnosed:
        return 'diagnosed';
      case CaseStatus.treated:
        return 'treated';
      case CaseStatus.resolved:
        return 'resolved';
      case CaseStatus.rejected:
        return 'rejected';
      case CaseStatus.escalated:
        return 'escalated';
    }
  }
  
  static CaseStatus fromApiValue(String value) {
    switch (value) {
      case 'pending':
        return CaseStatus.pending;
      case 'under_review':
        return CaseStatus.underReview;
      case 'investigation':
        return CaseStatus.investigation;
      case 'diagnosed':
        return CaseStatus.diagnosed;
      case 'treated':
        return CaseStatus.treated;
      case 'resolved':
        return CaseStatus.resolved;
      case 'rejected':
        return CaseStatus.rejected;
      case 'escalated':
        return CaseStatus.escalated;
      default:
        return CaseStatus.pending;
    }
  }
}

extension CaseUrgencyExtension on CaseUrgency {
  String get name {
    switch (this) {
      case CaseUrgency.low:
        return 'Low';
      case CaseUrgency.medium:
        return 'Medium';
      case CaseUrgency.high:
        return 'High';
      case CaseUrgency.urgent:
        return 'Urgent';
    }
  }
  
  String get apiValue {
    switch (this) {
      case CaseUrgency.low:
        return 'low';
      case CaseUrgency.medium:
        return 'medium';
      case CaseUrgency.high:
        return 'high';
      case CaseUrgency.urgent:
        return 'urgent';
    }
  }
  
  static CaseUrgency fromApiValue(String value) {
    switch (value) {
      case 'low':
        return CaseUrgency.low;
      case 'medium':
        return CaseUrgency.medium;
      case 'high':
        return CaseUrgency.high;
      case 'urgent':
        return CaseUrgency.urgent;
      default:
        return CaseUrgency.medium;
    }
  }
}

class CaseReport {
  final int id;
  final String caseId;
  final int reporterId;
  final int livestockId;
  final CaseStatus status;
  final CaseUrgency urgency;
  final String symptomsObserved;
  final String? durationOfSymptoms;
  final int numberOfAffectedAnimals;
  final int? suspectedDiseaseId;
  final List<String> photos;
  final List<String> videos;
  final List<String> audioNotes;
  final String? locationNotes;
  final DateTime reportedAt;
  final DateTime updatedAt;
  
  // Related data (populated from API)
  final String? livestockName;
  final String? livestockType;
  final String? reporterName;
  final String? reporterPhone;
  final String? reporterEmail;
  final String? assignedVeterinarianName;
  final String? assignedVeterinarianPhone;
  final String? assignedVeterinarianEmail;
  
  // Farmer confirmation fields
  final bool farmerConfirmedCompletion;
  final DateTime? farmerConfirmedAt;

  const CaseReport({
    required this.id,
    required this.caseId,
    required this.reporterId,
    required this.livestockId,
    required this.status,
    required this.urgency,
    required this.symptomsObserved,
    this.durationOfSymptoms,
    required this.numberOfAffectedAnimals,
    this.suspectedDiseaseId,
    this.photos = const [],
    this.videos = const [],
    this.audioNotes = const [],
    this.locationNotes,
    required this.reportedAt,
    required this.updatedAt,
    this.livestockName,
    this.livestockType,
    this.reporterName,
    this.reporterPhone,
    this.reporterEmail,
    this.assignedVeterinarianName,
    this.assignedVeterinarianPhone,
    this.assignedVeterinarianEmail,
    this.farmerConfirmedCompletion = false,
    this.farmerConfirmedAt,
  });

  factory CaseReport.fromMap(Map<String, dynamic> map) {
    return CaseReport(
      id: map['id'] ?? 0,
      caseId: map['case_id'] ?? '',
      reporterId: map['reporter'] is int ? map['reporter'] : int.tryParse(map['reporter']?.toString() ?? '0') ?? 0,
      livestockId: map['livestock'] is int ? map['livestock'] : int.tryParse(map['livestock']?.toString() ?? '0') ?? 0,
      status: CaseStatusExtension.fromApiValue(map['status'] ?? 'pending'),
      urgency: CaseUrgencyExtension.fromApiValue(map['urgency'] ?? 'medium'),
      symptomsObserved: map['symptoms_observed'] ?? '',
      durationOfSymptoms: map['duration_of_symptoms'],
      numberOfAffectedAnimals: map['number_of_affected_animals'] ?? 1,
      suspectedDiseaseId: map['suspected_disease'],
      photos: List<String>.from(map['photos'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      audioNotes: List<String>.from(map['audio_notes'] ?? []),
      locationNotes: map['location_notes'],
      reportedAt: map['reported_at'] != null 
          ? DateTime.parse(map['reported_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      livestockName: map['livestock_name'],
      livestockType: map['livestock_type'],
      reporterName: map['reporter_name'],
      reporterPhone: map['reporter_phone'],
      reporterEmail: map['reporter_email'],
      assignedVeterinarianName: map['assigned_veterinarian_name'],
      assignedVeterinarianPhone: map['assigned_veterinarian_phone'],
      assignedVeterinarianEmail: map['assigned_veterinarian_email'],
      farmerConfirmedCompletion: (map['farmer_confirmed_completion'] == true) || (map['farmer_confirmed_completion'] == 1) || (map['farmer_confirmed_completion'] == 'true'),
      farmerConfirmedAt: map['farmer_confirmed_at'] != null 
          ? DateTime.parse(map['farmer_confirmed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestock': livestockId,
      'status': status.apiValue,
      'urgency': urgency.apiValue,
      'symptoms_observed': symptomsObserved,
      'duration_of_symptoms': durationOfSymptoms,
      'number_of_affected_animals': numberOfAffectedAnimals,
      'suspected_disease': suspectedDiseaseId,
      'photos': photos,
      'videos': videos,
      'audio_notes': audioNotes,
      'location_notes': locationNotes,
    };
  }

  String toJson() => json.encode(toMap());
  factory CaseReport.fromJson(String source) => CaseReport.fromMap(json.decode(source));

  CaseReport copyWith({
    int? id,
    String? caseId,
    int? reporterId,
    int? livestockId,
    CaseStatus? status,
    CaseUrgency? urgency,
    String? symptomsObserved,
    String? durationOfSymptoms,
    int? numberOfAffectedAnimals,
    int? suspectedDiseaseId,
    List<String>? photos,
    List<String>? videos,
    List<String>? audioNotes,
    String? locationNotes,
    DateTime? reportedAt,
    DateTime? updatedAt,
    String? livestockName,
    String? livestockType,
    String? reporterName,
    String? reporterPhone,
    String? reporterEmail,
    String? assignedVeterinarianName,
    String? assignedVeterinarianPhone,
    String? assignedVeterinarianEmail,
    bool? farmerConfirmedCompletion,
    DateTime? farmerConfirmedAt,
  }) {
    return CaseReport(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      reporterId: reporterId ?? this.reporterId,
      livestockId: livestockId ?? this.livestockId,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      symptomsObserved: symptomsObserved ?? this.symptomsObserved,
      durationOfSymptoms: durationOfSymptoms ?? this.durationOfSymptoms,
      numberOfAffectedAnimals: numberOfAffectedAnimals ?? this.numberOfAffectedAnimals,
      suspectedDiseaseId: suspectedDiseaseId ?? this.suspectedDiseaseId,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      audioNotes: audioNotes ?? this.audioNotes,
      locationNotes: locationNotes ?? this.locationNotes,
      reportedAt: reportedAt ?? this.reportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      livestockName: livestockName ?? this.livestockName,
      livestockType: livestockType ?? this.livestockType,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      assignedVeterinarianName: assignedVeterinarianName ?? this.assignedVeterinarianName,
      assignedVeterinarianPhone: assignedVeterinarianPhone ?? this.assignedVeterinarianPhone,
      assignedVeterinarianEmail: assignedVeterinarianEmail ?? this.assignedVeterinarianEmail,
      farmerConfirmedCompletion: farmerConfirmedCompletion ?? this.farmerConfirmedCompletion,
      farmerConfirmedAt: farmerConfirmedAt ?? this.farmerConfirmedAt,
    );
  }
}

