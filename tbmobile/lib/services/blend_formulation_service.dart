import '../data/models/blend.dart';
import '../data/models/blend_ingredient.dart';
import '../data/models/ingredient.dart';
import '../data/models/base_mix.dart';
import '../data/repositories/blend_repository.dart';
import '../data/repositories/ingredient_repository.dart';

class BlendFormulationService {
  final BlendRepository _blendRepository = BlendRepository();
  final IngredientRepository _ingredientRepository = IngredientRepository();

  // Validate if ingredient amount is within allowed range
  bool validateIngredientAmount(
    Ingredient ingredient,
    double amount,
    bool isPractitioner,
  ) {
    final maxRange = isPractitioner 
        ? ingredient.practitionerMaxRange 
        : ingredient.customerMaxRange;
    
    return amount >= ingredient.minRange && amount <= maxRange;
  }

  // Get dosage validation for an ingredient
  DosageValidation getDosageValidation(
    Ingredient ingredient,
    double amount,
    bool isPractitioner,
  ) {
    final maxRange = isPractitioner 
        ? ingredient.practitionerMaxRange 
        : ingredient.customerMaxRange;
    
    if (amount < ingredient.minRange) {
      return DosageValidation(
        isValid: false,
        message: 'Below minimum range (${ingredient.minRange}${ingredient.unitDisplay})',
        severity: DosageSeverity.error,
      );
    }
    
    if (amount > maxRange) {
      return DosageValidation(
        isValid: false,
        message: 'Exceeds maximum range (${maxRange}${ingredient.unitDisplay})',
        severity: DosageSeverity.error,
      );
    }
    
    if (amount < ingredient.recommendedRange * 0.8) {
      return DosageValidation(
        isValid: true,
        message: 'Below recommended range',
        severity: DosageSeverity.warning,
      );
    }
    
    if (amount > ingredient.recommendedRange * 1.2) {
      return DosageValidation(
        isValid: true,
        message: 'Above recommended range',
        severity: DosageSeverity.warning,
      );
    }
    
    return DosageValidation(
      isValid: true,
      message: 'Within recommended range',
      severity: DosageSeverity.success,
    );
  }

  // Validate total blend weight against base mix limits
  bool validateBlendWeight(BaseMix baseMix, double totalWeight) {
    return baseMix.isWithinRange(totalWeight);
  }

  // Calculate blend total from ingredients
  double calculateBlendTotal(List<BlendIngredient> ingredients) {
    return ingredients.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Check for ingredient interactions or conflicts
  Future<List<String>> checkIngredientInteractions(
    List<int> ingredientIds,
  ) async {
    List<String> warnings = [];
    
    // This would typically check a database of known interactions
    // For now, we'll implement basic rules
    
    List<Ingredient> ingredients = [];
    for (int id in ingredientIds) {
      final ingredient = await _ingredientRepository.getIngredient(id);
      if (ingredient != null) {
        ingredients.add(ingredient);
      }
    }
    
    // Check for duplicate categories
    Map<String, List<String>> categoryIngredients = {};
    for (var ingredient in ingredients) {
      for (var category in ingredient.healthCategories) {
        categoryIngredients.putIfAbsent(category, () => []);
        categoryIngredients[category]!.add(ingredient.name);
      }
    }
    
    // Warn if multiple ingredients target the same category
    categoryIngredients.forEach((category, names) {
      if (names.length > 2) {
        warnings.add('Multiple ingredients targeting $category: ${names.join(", ")}');
      }
    });
    
    return warnings;
  }

  // Generate ingredient recommendations based on health goals
  Future<List<Ingredient>> recommendIngredients(
    List<String> healthGoals,
    List<int> existingIngredientIds,
  ) async {
    // Get ingredients matching health goals
    final recommended = await _ingredientRepository.getRecommendedIngredients(healthGoals);
    
    // Filter out already selected ingredients
    return recommended.where((ing) => !existingIngredientIds.contains(ing.ingredientId)).toList();
  }

  // Create a new blend
  Future<Blend> createBlend({
    required String name,
    required int baseMixId,
    required int formulatedBy,
    int? formulatedFor,
    String? description,
    String? notes,
    required List<BlendIngredient> ingredients,
  }) async {
    // Calculate total amount
    final totalAmount = calculateBlendTotal(ingredients);
    
    // Create the blend
    final blend = Blend(
      name: name,
      baseMixId: baseMixId,
      formulatedBy: formulatedBy,
      formulatedFor: formulatedFor,
      description: description,
      notes: notes,
      totalAmount: totalAmount,
      createdDate: DateTime.now(),
      modifiedDate: DateTime.now(),
      blendStatus: 'draft',
    );
    
    // Save to database
    final blendId = await _blendRepository.createBlend(blend);
    
    // Add ingredients
    for (var ingredient in ingredients) {
      await _blendRepository.addIngredientToBlend(
        ingredient.copyWith(blendId: blendId),
      );
    }
    
    // Return the created blend with ID
    return blend.copyWith(blendId: blendId, ingredients: ingredients);
  }

  // Duplicate an existing blend
  Future<Blend> duplicateBlend(int blendId, String newName) async {
    final originalBlend = await _blendRepository.getBlend(blendId);
    if (originalBlend == null) {
      throw Exception('Blend not found');
    }
    
    return createBlend(
      name: newName,
      baseMixId: originalBlend.baseMixId,
      formulatedBy: originalBlend.formulatedBy!,
      formulatedFor: originalBlend.formulatedFor,
      description: 'Duplicated from: ${originalBlend.name}',
      notes: originalBlend.notes,
      ingredients: originalBlend.ingredients ?? [],
    );
  }

  // Optimize blend for cost
  Future<List<BlendIngredient>> optimizeForCost(
    List<BlendIngredient> ingredients,
    double targetReduction,
  ) async {
    // Sort ingredients by price per mg
    List<IngredientWithPrice> priced = [];
    
    for (var blendIngredient in ingredients) {
      final ingredient = await _ingredientRepository.getIngredient(blendIngredient.ingredientId);
      if (ingredient != null && ingredient.retailPrice != null) {
        priced.add(IngredientWithPrice(
          blendIngredient: blendIngredient,
          ingredient: ingredient,
          pricePerUnit: ingredient.retailPrice! / 1000, // Price per mg
        ));
      }
    }
    
    // Sort by price (most expensive first)
    priced.sort((a, b) => b.pricePerUnit.compareTo(a.pricePerUnit));
    
    // Reduce expensive ingredients to their minimum
    List<BlendIngredient> optimized = [];
    for (var item in priced) {
      if (targetReduction > 0) {
        final reduction = (item.blendIngredient.amount - item.ingredient.minRange) * 0.5;
        if (reduction > 0) {
          optimized.add(item.blendIngredient.copyWith(
            amount: item.blendIngredient.amount - reduction,
          ));
          targetReduction -= reduction * item.pricePerUnit;
        } else {
          optimized.add(item.blendIngredient);
        }
      } else {
        optimized.add(item.blendIngredient);
      }
    }
    
    return optimized;
  }
}

class DosageValidation {
  final bool isValid;
  final String message;
  final DosageSeverity severity;

  DosageValidation({
    required this.isValid,
    required this.message,
    required this.severity,
  });
}

enum DosageSeverity { success, warning, error }

class IngredientWithPrice {
  final BlendIngredient blendIngredient;
  final Ingredient ingredient;
  final double pricePerUnit;

  IngredientWithPrice({
    required this.blendIngredient,
    required this.ingredient,
    required this.pricePerUnit,
  });
}