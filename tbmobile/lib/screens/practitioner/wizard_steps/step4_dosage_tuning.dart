import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/blend_wizard_provider.dart';
import '../../../data/models/ingredient.dart';
import '../../../services/blend_formulation_service.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/floating_card.dart';

class Step4DosageTuning extends StatefulWidget {
  const Step4DosageTuning({super.key});

  @override
  State<Step4DosageTuning> createState() => _Step4DosageTuningState();
}

class _Step4DosageTuningState extends State<Step4DosageTuning> {
  Map<int, Ingredient> _ingredients = {};
  
  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }
  
  Future<void> _loadIngredients() async {
    final provider = Provider.of<BlendWizardProvider>(context, listen: false);
    final ingredients = <int, Ingredient>{};
    
    for (var id in provider.selectedIngredients.keys) {
      final ingredient = provider.availableIngredients.firstWhere(
        (ing) => ing.ingredientId == id,
        orElse: () => provider.recommendedIngredients.firstWhere(
          (ing) => ing.ingredientId == id,
        ),
      );
      ingredients[id] = ingredient;
    }
    
    setState(() {
      _ingredients = ingredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        final baseMix = provider.selectedBaseMix;
        final totalWeight = provider.totalWeight;
        final isWithinRange = baseMix?.isWithinRange(totalWeight) ?? true;
        
        return Column(
          children: [
            // Weight summary header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isWithinRange
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.error.withValues(alpha: 0.1),
                    AppTheme.getSurfaceColor(context),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Blend Weight',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${totalWeight.toStringAsFixed(1)}g',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWithinRange ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                  if (baseMix != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isWithinRange ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: isWithinRange ? AppTheme.success : AppTheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isWithinRange
                              ? 'Within ${baseMix.name} range (${baseMix.rangeDisplay})'
                              : 'Outside ${baseMix.name} range (${baseMix.rangeDisplay})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isWithinRange ? AppTheme.success : AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Weight range indicator
                    _buildWeightRangeIndicator(
                      context,
                      baseMix.minQuantity,
                      baseMix.maxQuantity,
                      totalWeight,
                    ),
                  ],
                ],
              ),
            ),
            
            // Ingredients list with sliders
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Fine-tune Dosages',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust individual ingredient amounts to optimize the blend',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._ingredients.entries.map((entry) {
                    final ingredient = entry.value;
                    final amount = provider.selectedIngredients[entry.key] ?? 0;
                    final validation = provider.dosageValidations[entry.key];
                    
                    return _buildIngredientDosageCard(
                      context,
                      ingredient,
                      amount,
                      validation,
                      (newAmount) => provider.updateDosage(ingredient, newAmount),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeightRangeIndicator(
    BuildContext context,
    double min,
    double max,
    double current,
  ) {
    final range = max - min;
    final position = ((current - min) / range).clamp(0.0, 1.0);
    final isWithinRange = current >= min && current <= max;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        children: [
          // Valid range background
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.success.withValues(alpha: 0.2),
                  AppTheme.success.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Current position indicator
          Positioned(
            left: 8 + (position * (MediaQuery.of(context).size.width - 80)),
            top: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isWithinRange ? AppTheme.success : AppTheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isWithinRange ? AppTheme.success : AppTheme.error)
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.circle,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          // Labels
          Positioned(
            left: 12,
            bottom: 2,
            child: Text(
              '${min.toStringAsFixed(0)}g',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 2,
            child: Text(
              '${max.toStringAsFixed(0)}g',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientDosageCard(
    BuildContext context,
    Ingredient ingredient,
    double amount,
    DosageValidation? validation,
    Function(double) onChanged,
  ) {
    final severityColor = validation?.severity == DosageSeverity.error
        ? AppTheme.error
        : validation?.severity == DosageSeverity.warning
            ? AppTheme.warning
            : AppTheme.success;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FloatingCard(
        glassmorphic: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: ingredient.healthCategories.map((category) {
                          return Text(
                            category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: severityColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${amount.toStringAsFixed(0)}${ingredient.unitDisplay}',
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Slider
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: severityColor,
                    inactiveTrackColor: severityColor.withValues(alpha: 0.2),
                    thumbColor: severityColor,
                    overlayColor: severityColor.withValues(alpha: 0.3),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: amount,
                    min: ingredient.minRange,
                    max: ingredient.customerMaxRange,
                    divisions: ((ingredient.customerMaxRange - ingredient.minRange) / 
                               (ingredient.unitOfMeasure == 134 ? 10 : 1)).round(),
                    onChanged: onChanged,
                  ),
                ),
                // Range labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ingredient.minRange.toStringAsFixed(0)}${ingredient.unitDisplay}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Recommended: ${ingredient.recommendedRange.toStringAsFixed(0)}${ingredient.unitDisplay}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      Text(
                        '${ingredient.customerMaxRange.toStringAsFixed(0)}${ingredient.unitDisplay}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Validation message
            if (validation != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    validation.severity == DosageSeverity.error
                        ? Icons.error
                        : validation.severity == DosageSeverity.warning
                            ? Icons.warning
                            : Icons.check_circle,
                    size: 16,
                    color: severityColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    validation.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: severityColor,
                    ),
                  ),
                ],
              ),
            ],
            
            // Quick adjustment buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => onChanged(ingredient.minRange),
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('Min'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onChanged(ingredient.recommendedRange),
                  icon: const Icon(Icons.recommend, size: 18),
                  label: const Text('Recommended'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.getPrimaryColor(context),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onChanged(ingredient.customerMaxRange),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Max'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}