class Practitioner {
  final int? practitionerId;
  final int userId;
  final String? specializesIn;
  final String? biography;
  final bool isActive;
  final double? commissionBasic;
  final double? commissionSpecial;
  final DateTime? createdDate;

  Practitioner({
    this.practitionerId,
    required this.userId,
    this.specializesIn,
    this.biography,
    this.isActive = true,
    this.commissionBasic,
    this.commissionSpecial,
    this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'practitioner_id': practitionerId,
      'user_id': userId,
      'specializes_in': specializesIn,
      'biography': biography,
      'is_active': isActive ? 1 : 0,
      'commission_basic': commissionBasic,
      'commission_special': commissionSpecial,
      'created_date': createdDate?.toIso8601String(),
    };
  }

  factory Practitioner.fromMap(Map<String, dynamic> map) {
    return Practitioner(
      practitionerId: map['practitioner_id'],
      userId: map['user_id'],
      specializesIn: map['specializes_in'],
      biography: map['biography'],
      isActive: map['is_active'] == 1,
      commissionBasic: map['commission_basic']?.toDouble(),
      commissionSpecial: map['commission_special']?.toDouble(),
      createdDate: map['created_date'] != null
          ? DateTime.parse(map['created_date'])
          : null,
    );
  }

  Practitioner copyWith({
    int? practitionerId,
    int? userId,
    String? specializesIn,
    String? biography,
    bool? isActive,
    double? commissionBasic,
    double? commissionSpecial,
    DateTime? createdDate,
  }) {
    return Practitioner(
      practitionerId: practitionerId ?? this.practitionerId,
      userId: userId ?? this.userId,
      specializesIn: specializesIn ?? this.specializesIn,
      biography: biography ?? this.biography,
      isActive: isActive ?? this.isActive,
      commissionBasic: commissionBasic ?? this.commissionBasic,
      commissionSpecial: commissionSpecial ?? this.commissionSpecial,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class PractitionerClient {
  final int? id;
  final int practitionerId;
  final int clientId;
  final bool isValidated;
  final String referenceNumber;
  final DateTime? createdDate;

  PractitionerClient({
    this.id,
    required this.practitionerId,
    required this.clientId,
    this.isValidated = false,
    required this.referenceNumber,
    this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practitioner_id': practitionerId,
      'client_id': clientId,
      'is_validated': isValidated ? 1 : 0,
      'reference_number': referenceNumber,
      'created_date': createdDate?.toIso8601String(),
    };
  }

  factory PractitionerClient.fromMap(Map<String, dynamic> map) {
    return PractitionerClient(
      id: map['id'],
      practitionerId: map['practitioner_id'],
      clientId: map['client_id'],
      isValidated: map['is_validated'] == 1,
      referenceNumber: map['reference_number'],
      createdDate: map['created_date'] != null
          ? DateTime.parse(map['created_date'])
          : null,
    );
  }

  static String generateReferenceNumber() {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'REF${random.toString().padLeft(4, '0')}';
  }
}