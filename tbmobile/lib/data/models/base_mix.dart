class BaseMix {
  final int baseMixId;
  final String name;
  final int type;
  final double minQuantity;
  final double maxQuantity;
  final bool isVegan;

  BaseMix({
    required this.baseMixId,
    required this.name,
    required this.type,
    required this.minQuantity,
    required this.maxQuantity,
    this.isVegan = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'base_mix_id': baseMixId,
      'name': name,
      'type': type,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'is_vegan': isVegan ? 1 : 0,
    };
  }

  factory BaseMix.fromMap(Map<String, dynamic> map) {
    return BaseMix(
      baseMixId: map['base_mix_id'],
      name: map['name'],
      type: map['type'],
      minQuantity: (map['min_quantity'] ?? 0).toDouble(),
      maxQuantity: (map['max_quantity'] ?? 0).toDouble(),
      isVegan: map['is_vegan'] == 1,
    );
  }

  bool isWithinRange(double amount) {
    return amount >= minQuantity && amount <= maxQuantity;
  }

  double getRemainingCapacity(double currentAmount) {
    return maxQuantity - currentAmount;
  }

  String get typeDisplay {
    switch (type) {
      case 53:
        return isVegan ? 'Vegan Shake' : 'Whey Shake';
      case 54:
        return 'Drink';
      case 213:
        return 'Nutriblend-F';
      case 217:
        return 'Active Ingredients Only';
      default:
        return name;
    }
  }

  String get rangeDisplay {
    return '${minQuantity.toStringAsFixed(1)}g - ${maxQuantity.toStringAsFixed(1)}g';
  }
}