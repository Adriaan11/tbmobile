import 'blend_ingredient.dart';

class Blend {
  final int? blendId;
  final String? blendUid;
  final String name;
  final int? formulatedFor;
  final int? formulatedBy;
  final String? description;
  final String? notes;
  final int baseMixId;
  final String? blendStatus;
  final double? totalAmount;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final bool isSynced;
  final int? serverBlendId;
  final List<BlendIngredient>? ingredients;

  Blend({
    this.blendId,
    this.blendUid,
    required this.name,
    this.formulatedFor,
    this.formulatedBy,
    this.description,
    this.notes,
    required this.baseMixId,
    this.blendStatus,
    this.totalAmount,
    this.createdDate,
    this.modifiedDate,
    this.isSynced = false,
    this.serverBlendId,
    this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'blend_id': blendId,
      'blend_uid': blendUid ?? _generateUid(),
      'name': name,
      'formulated_for': formulatedFor,
      'formulated_by': formulatedBy,
      'description': description,
      'notes': notes,
      'base_mix_id': baseMixId,
      'blend_status': blendStatus ?? 'draft',
      'total_amount': totalAmount ?? calculateTotalAmount(),
      'created_date': createdDate?.toIso8601String(),
      'modified_date': modifiedDate?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_blend_id': serverBlendId,
    };
  }

  factory Blend.fromMap(Map<String, dynamic> map) {
    return Blend(
      blendId: map['blend_id'],
      blendUid: map['blend_uid'],
      name: map['name'],
      formulatedFor: map['formulated_for'],
      formulatedBy: map['formulated_by'],
      description: map['description'],
      notes: map['notes'],
      baseMixId: map['base_mix_id'],
      blendStatus: map['blend_status'],
      totalAmount: map['total_amount']?.toDouble(),
      createdDate: map['created_date'] != null 
          ? DateTime.parse(map['created_date']) 
          : null,
      modifiedDate: map['modified_date'] != null 
          ? DateTime.parse(map['modified_date']) 
          : null,
      isSynced: map['is_synced'] == 1,
      serverBlendId: map['server_blend_id'],
    );
  }

  static String _generateUid() {
    final now = DateTime.now();
    return 'BLD-${now.millisecondsSinceEpoch}';
  }

  double calculateTotalAmount() {
    if (ingredients == null || ingredients!.isEmpty) return 0.0;
    return ingredients!.fold(0.0, (sum, item) => sum + item.amount);
  }

  Blend copyWith({
    int? blendId,
    String? blendUid,
    String? name,
    int? formulatedFor,
    int? formulatedBy,
    String? description,
    String? notes,
    int? baseMixId,
    String? blendStatus,
    double? totalAmount,
    DateTime? createdDate,
    DateTime? modifiedDate,
    bool? isSynced,
    int? serverBlendId,
    List<BlendIngredient>? ingredients,
  }) {
    return Blend(
      blendId: blendId ?? this.blendId,
      blendUid: blendUid ?? this.blendUid,
      name: name ?? this.name,
      formulatedFor: formulatedFor ?? this.formulatedFor,
      formulatedBy: formulatedBy ?? this.formulatedBy,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      baseMixId: baseMixId ?? this.baseMixId,
      blendStatus: blendStatus ?? this.blendStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      isSynced: isSynced ?? this.isSynced,
      serverBlendId: serverBlendId ?? this.serverBlendId,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}