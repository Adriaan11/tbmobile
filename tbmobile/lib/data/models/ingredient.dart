class Ingredient {
  final int ingredientId;
  final String name;
  final String? labelName;
  final int? category;
  final double minRange;
  final double recommendedRange;
  final double customerMaxRange;
  final double practitionerMaxRange;
  final bool isVegan;
  final bool isVegetarian;
  final bool glutenFree;
  final bool cognitive;
  final bool energy;
  final bool immune;
  final bool muscle;
  final bool wellness;
  final bool beauty;
  final bool sleep;
  final bool femaleHealth;
  final int? unitOfMeasure;
  final double? retailPrice;
  final String? benefits;
  final String? warnings;
  final bool isInStock;

  Ingredient({
    required this.ingredientId,
    required this.name,
    this.labelName,
    this.category,
    required this.minRange,
    required this.recommendedRange,
    required this.customerMaxRange,
    required this.practitionerMaxRange,
    this.isVegan = false,
    this.isVegetarian = false,
    this.glutenFree = false,
    this.cognitive = false,
    this.energy = false,
    this.immune = false,
    this.muscle = false,
    this.wellness = false,
    this.beauty = false,
    this.sleep = false,
    this.femaleHealth = false,
    this.unitOfMeasure,
    this.retailPrice,
    this.benefits,
    this.warnings,
    this.isInStock = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredient_id': ingredientId,
      'name': name,
      'label_name': labelName,
      'category': category,
      'min_range': minRange,
      'recommended_range': recommendedRange,
      'customer_max_range': customerMaxRange,
      'practitioner_max_range': practitionerMaxRange,
      'is_vegan': isVegan ? 1 : 0,
      'is_vegetarian': isVegetarian ? 1 : 0,
      'gluten_free': glutenFree ? 1 : 0,
      'cognitive': cognitive ? 1 : 0,
      'energy': energy ? 1 : 0,
      'immune': immune ? 1 : 0,
      'muscle': muscle ? 1 : 0,
      'wellness': wellness ? 1 : 0,
      'beauty': beauty ? 1 : 0,
      'sleep': sleep ? 1 : 0,
      'female_health': femaleHealth ? 1 : 0,
      'unit_of_measure': unitOfMeasure,
      'retail_price': retailPrice,
      'benefits': benefits,
      'warnings': warnings,
      'is_in_stock': isInStock ? 1 : 0,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientId: map['ingredient_id'],
      name: map['name'],
      labelName: map['label_name'],
      category: map['category'],
      minRange: (map['min_range'] ?? 0).toDouble(),
      recommendedRange: (map['recommended_range'] ?? 0).toDouble(),
      customerMaxRange: (map['customer_max_range'] ?? 0).toDouble(),
      practitionerMaxRange: (map['practitioner_max_range'] ?? 0).toDouble(),
      isVegan: map['is_vegan'] == 1,
      isVegetarian: map['is_vegetarian'] == 1,
      glutenFree: map['gluten_free'] == 1,
      cognitive: map['cognitive'] == 1,
      energy: map['energy'] == 1,
      immune: map['immune'] == 1,
      muscle: map['muscle'] == 1,
      wellness: map['wellness'] == 1,
      beauty: map['beauty'] == 1,
      sleep: map['sleep'] == 1,
      femaleHealth: map['female_health'] == 1,
      unitOfMeasure: map['unit_of_measure'],
      retailPrice: map['retail_price']?.toDouble(),
      benefits: map['benefits'],
      warnings: map['warnings'],
      isInStock: map['is_in_stock'] == 1,
    );
  }

  List<String> get healthCategories {
    final categories = <String>[];
    if (cognitive) categories.add('Cognitive');
    if (energy) categories.add('Energy');
    if (immune) categories.add('Immune');
    if (muscle) categories.add('Muscle');
    if (wellness) categories.add('Wellness');
    if (beauty) categories.add('Beauty');
    if (sleep) categories.add('Sleep');
    if (femaleHealth) categories.add('Female Health');
    return categories;
  }

  List<String> get dietaryInfo {
    final info = <String>[];
    if (isVegan) info.add('Vegan');
    if (isVegetarian) info.add('Vegetarian');
    if (glutenFree) info.add('Gluten Free');
    return info;
  }

  String get unitDisplay {
    switch (unitOfMeasure) {
      case 133:
        return 'mg';
      case 134:
        return 'mcg';
      case 135:
        return 'g';
      case 136:
        return 'IU';
      default:
        return 'mg';
    }
  }

  double getMaxRange(bool isPractitioner) {
    return isPractitioner ? practitionerMaxRange : customerMaxRange;
  }
}