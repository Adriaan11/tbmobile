class BlendIngredient {
  final int? id;
  final int blendId;
  final int ingredientId;
  final double amount;
  final int? sequence;
  final String? ingredientName; // For display purposes
  final String? unitOfMeasure; // For display purposes

  BlendIngredient({
    this.id,
    required this.blendId,
    required this.ingredientId,
    required this.amount,
    this.sequence,
    this.ingredientName,
    this.unitOfMeasure,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blend_id': blendId,
      'ingredient_id': ingredientId,
      'amount': amount,
      'sequence': sequence,
    };
  }

  factory BlendIngredient.fromMap(Map<String, dynamic> map) {
    return BlendIngredient(
      id: map['id'],
      blendId: map['blend_id'],
      ingredientId: map['ingredient_id'],
      amount: (map['amount'] ?? 0).toDouble(),
      sequence: map['sequence'],
      ingredientName: map['ingredient_name'],
      unitOfMeasure: map['unit_of_measure'],
    );
  }

  BlendIngredient copyWith({
    int? id,
    int? blendId,
    int? ingredientId,
    double? amount,
    int? sequence,
    String? ingredientName,
    String? unitOfMeasure,
  }) {
    return BlendIngredient(
      id: id ?? this.id,
      blendId: blendId ?? this.blendId,
      ingredientId: ingredientId ?? this.ingredientId,
      amount: amount ?? this.amount,
      sequence: sequence ?? this.sequence,
      ingredientName: ingredientName ?? this.ingredientName,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
    );
  }
}