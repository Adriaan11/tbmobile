import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/blend_wizard_provider.dart';
import '../../../data/models/ingredient.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/floating_card.dart';

class Step3Ingredients extends StatefulWidget {
  const Step3Ingredients({super.key});

  @override
  State<Step3Ingredients> createState() => _Step3IngredientsState();
}

class _Step3IngredientsState extends State<Step3Ingredients> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  
  final List<String> _categories = [
    'All',
    'Cognitive',
    'Energy',
    'Immune',
    'Muscle',
    'Wellness',
    'Beauty',
    'Sleep',
    'Female Health',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ingredient> _filterIngredients(BlendWizardProvider provider) {
    List<Ingredient> ingredients = provider.availableIngredients;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      ingredients = ingredients.where((ing) => 
        ing.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != null && _selectedCategory != 'All') {
      ingredients = ingredients.where((ing) {
        switch (_selectedCategory) {
          case 'Cognitive':
            return ing.cognitive;
          case 'Energy':
            return ing.energy;
          case 'Immune':
            return ing.immune;
          case 'Muscle':
            return ing.muscle;
          case 'Wellness':
            return ing.wellness;
          case 'Beauty':
            return ing.beauty;
          case 'Sleep':
            return ing.sleep;
          case 'Female Health':
            return ing.femaleHealth;
          default:
            return true;
        }
      }).toList();
    }
    
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        final filteredIngredients = _filterIngredients(provider);
        final recommendedIngredients = provider.recommendedIngredients;
        
        return Column(
          children: [
            // Search and filter header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ingredients...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category filter chips
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category ||
                            (category == 'All' && _selectedCategory == null);
                        
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category == 'All' ? null : category;
                            });
                          },
                          backgroundColor: AppTheme.getSurfaceColor(context),
                          selectedColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.15),
                          checkmarkColor: AppTheme.getPrimaryColor(context),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Selected count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.selectedIngredients.length} ingredients selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      Text(
                        '${filteredIngredients.length} available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Ingredients list
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Recommended section
                        if (recommendedIngredients.isNotEmpty && _searchQuery.isEmpty) ...[
                          _buildSectionHeader(
                            context,
                            'Recommended for Selected Goals',
                            Icons.star,
                            AppTheme.warning,
                          ),
                          const SizedBox(height: 12),
                          ...recommendedIngredients.take(5).map(
                            (ingredient) => _buildIngredientTile(
                              context,
                              ingredient,
                              provider,
                              isRecommended: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // All ingredients section
                        _buildSectionHeader(
                          context,
                          _selectedCategory != null 
                              ? '$_selectedCategory Ingredients'
                              : 'All Ingredients',
                          Icons.inventory_2,
                          AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(height: 12),
                        
                        if (filteredIngredients.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No ingredients found',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.getTextSecondaryColor(context),
                                ),
                              ),
                            ),
                          )
                        else
                          ...filteredIngredients.map(
                            (ingredient) => _buildIngredientTile(
                              context,
                              ingredient,
                              provider,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientTile(
    BuildContext context,
    Ingredient ingredient,
    BlendWizardProvider provider, {
    bool isRecommended = false,
  }) {
    final isSelected = provider.isIngredientSelected(ingredient.ingredientId);
    final amount = provider.selectedIngredients[ingredient.ingredientId] ?? 
                   ingredient.recommendedRange;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FloatingCard(
        glassmorphic: !isSelected,
        onTap: () => provider.toggleIngredient(ingredient),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.getPrimaryColor(context)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.getPrimaryColor(context)
                          : AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ingredient.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: AppTheme.warning,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Recommended',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Range: ${ingredient.minRange.toStringAsFixed(0)}-${ingredient.customerMaxRange.toStringAsFixed(0)}${ingredient.unitDisplay} '
                        '(Recommended: ${ingredient.recommendedRange.toStringAsFixed(0)}${ingredient.unitDisplay})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount display
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${amount.toStringAsFixed(0)}${ingredient.unitDisplay}',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            // Health categories
            if (ingredient.healthCategories.isNotEmpty || ingredient.dietaryInfo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...ingredient.healthCategories.map((category) => _buildTag(
                    context,
                    category,
                    AppTheme.getPrimaryColor(context),
                  )),
                  ...ingredient.dietaryInfo.map((info) => _buildTag(
                    context,
                    info,
                    AppTheme.success,
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}