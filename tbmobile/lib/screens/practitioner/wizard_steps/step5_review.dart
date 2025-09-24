import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/blend_wizard_provider.dart';
import '../../../data/models/ingredient.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/floating_card.dart';

class Step5Review extends StatefulWidget {
  const Step5Review({super.key});

  @override
  State<Step5Review> createState() => _Step5ReviewState();
}

class _Step5ReviewState extends State<Step5Review> {
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
        final client = provider.selectedClient;
        final baseMix = provider.selectedBaseMix;
        final totalWeight = provider.totalWeight;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Review Your Blend',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please review all details before creating the blend',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              
              // Warnings
              if (provider.warnings.isNotEmpty) ...[
                const SizedBox(height: 20),
                ..._buildWarningsSection(context, provider.warnings),
              ],
              
              const SizedBox(height: 24),
              
              // Blend summary card
              _buildSummaryCard(
                context: context,
                title: 'Blend Information',
                icon: Icons.info_outline,
                children: [
                  _buildSummaryRow('Name', provider.blendName),
                  if (provider.description.isNotEmpty)
                    _buildSummaryRow('Description', provider.description),
                  if (baseMix != null)
                    _buildSummaryRow('Base Mix', baseMix.name),
                  _buildSummaryRow('Total Weight', '${totalWeight.toStringAsFixed(1)}g'),
                  _buildSummaryRow('Ingredients Count', '${provider.selectedIngredients.length}'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Client information
              if (client != null)
                _buildSummaryCard(
                  context: context,
                  title: 'Client Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildSummaryRow('Name', '${client.firstName} ${client.lastName}'),
                    _buildSummaryRow('Email', client.email),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Health goals
              _buildSummaryCard(
                context: context,
                title: 'Health Goals',
                icon: Icons.track_changes,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.selectedHealthGoals.map((goal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Ingredients breakdown
              _buildIngredientsSection(context, provider),
              
              const SizedBox(height: 24),
              
              // Final confirmation
              FloatingCard(
                glassmorphic: false,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                    AppTheme.getSecondaryColor(context).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to Create Blend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Create Blend" to save this personalized formulation',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildWarningsSection(BuildContext context, List<String> warnings) {
    return [
      FloatingCard(
        glassmorphic: false,
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withValues(alpha: 0.1),
            AppTheme.warning.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppTheme.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Warnings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...warnings.map((warning) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      warning,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    ];
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return FloatingCard(
      glassmorphic: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.getPrimaryColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.getTextSecondaryColor(context),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context, BlendWizardProvider provider) {
    return FloatingCard(
      glassmorphic: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                size: 20,
                color: AppTheme.getPrimaryColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Ingredients Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Ingredient',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Amount',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Ingredients list
          ..._ingredients.entries.map((entry) {
            final ingredient = entry.value;
            final amount = provider.selectedIngredients[entry.key] ?? 0;
            final validation = provider.dosageValidations[entry.key];
            
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (validation != null && !validation.isValid) ...[
                          const SizedBox(height: 2),
                          Text(
                            validation.message,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.error,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${amount.toStringAsFixed(0)}${ingredient.unitDisplay}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: validation != null && !validation.isValid
                            ? AppTheme.error
                            : AppTheme.getTextPrimaryColor(context),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          // Total row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Total Weight',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${provider.totalWeight.toStringAsFixed(1)}g',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}