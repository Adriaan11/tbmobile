import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/blend_wizard_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/floating_card.dart';

class Step2HealthGoals extends StatelessWidget {
  const Step2HealthGoals({super.key});

  final List<HealthGoalCategory> _categories = const [
    HealthGoalCategory(
      name: 'Energy & Vitality',
      icon: Icons.bolt,
      color: Color(0xFFFF9800),
      goals: [
        HealthGoal('Energy', 'Boost daily energy levels', Icons.battery_charging_full),
        HealthGoal('Endurance', 'Improve physical stamina', Icons.trending_up),
        HealthGoal('Focus', 'Enhance mental clarity', Icons.psychology),
      ],
    ),
    HealthGoalCategory(
      name: 'Physical Performance',
      icon: Icons.fitness_center,
      color: Color(0xFF4CAF50),
      goals: [
        HealthGoal('Muscle', 'Build & maintain muscle', Icons.fitness_center),
        HealthGoal('Recovery', 'Faster post-workout recovery', Icons.healing),
        HealthGoal('Strength', 'Increase physical strength', Icons.sports_martial_arts),
      ],
    ),
    HealthGoalCategory(
      name: 'Cognitive Health',
      icon: Icons.psychology,
      color: Color(0xFF2196F3),
      goals: [
        HealthGoal('Cognitive', 'Support brain health', Icons.lightbulb),
        HealthGoal('Memory', 'Enhance memory retention', Icons.save_alt),
        HealthGoal('Concentration', 'Improve focus & attention', Icons.center_focus_strong),
      ],
    ),
    HealthGoalCategory(
      name: 'Immune System',
      icon: Icons.shield,
      color: Color(0xFF9C27B0),
      goals: [
        HealthGoal('Immune', 'Strengthen immune defenses', Icons.security),
        HealthGoal('Antioxidants', 'Combat oxidative stress', Icons.spa),
        HealthGoal('Inflammation', 'Reduce inflammation', Icons.local_fire_department),
      ],
    ),
    HealthGoalCategory(
      name: 'Sleep & Recovery',
      icon: Icons.bedtime,
      color: Color(0xFF607D8B),
      goals: [
        HealthGoal('Sleep', 'Improve sleep quality', Icons.nights_stay),
        HealthGoal('Relaxation', 'Promote calmness', Icons.self_improvement),
        HealthGoal('Stress', 'Manage stress levels', Icons.spa),
      ],
    ),
    HealthGoalCategory(
      name: 'Beauty & Wellness',
      icon: Icons.face,
      color: Color(0xFFE91E63),
      goals: [
        HealthGoal('Beauty', 'Skin, hair & nail health', Icons.face_retouching_natural),
        HealthGoal('Anti-aging', 'Support healthy aging', Icons.timeline),
        HealthGoal('Wellness', 'Overall well-being', Icons.favorite),
      ],
    ),
    HealthGoalCategory(
      name: 'Women\'s Health',
      icon: Icons.volunteer_activism,
      color: Color(0xFFFF4081),
      goals: [
        HealthGoal('Female Health', 'Women\'s specific needs', Icons.favorite_border),
        HealthGoal('Hormonal Balance', 'Support hormonal health', Icons.balance),
        HealthGoal('Bone Health', 'Maintain bone density', Icons.accessibility),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildSubheader(context, provider),
              const SizedBox(height: 24),
              ..._categories.map((category) => _buildCategorySection(
                context,
                category,
                provider,
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Select Health Goals',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppTheme.getTextPrimaryColor(context),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubheader(BuildContext context, BlendWizardProvider provider) {
    final count = provider.selectedHealthGoals.length;
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            count == 0
                ? 'Select at least one health goal to continue'
                : '$count goal${count == 1 ? '' : 's'} selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ),
        if (count > 0)
          TextButton(
            onPressed: () {
              for (var goal in provider.selectedHealthGoals.toList()) {
                provider.toggleHealthGoal(goal);
              }
            },
            child: const Text('Clear All'),
          ),
      ],
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    HealthGoalCategory category,
    BlendWizardProvider provider,
  ) {
    final hasSelectedGoals = category.goals.any(
      (goal) => provider.selectedHealthGoals.contains(goal.name),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasSelectedGoals
                      ? category.color
                      : AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: category.goals.map((goal) {
              final isSelected = provider.selectedHealthGoals.contains(goal.name);
              
              return InkWell(
                onTap: () => provider.toggleHealthGoal(goal.name),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.15)
                        : AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : AppTheme.getTextSecondaryColor(context).withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        goal.icon,
                        size: 18,
                        color: isSelected
                            ? category.color
                            : AppTheme.getTextSecondaryColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goal.name,
                        style: TextStyle(
                          color: isSelected
                              ? category.color
                              : AppTheme.getTextPrimaryColor(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: category.color,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class HealthGoalCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<HealthGoal> goals;

  const HealthGoalCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.goals,
  });
}

class HealthGoal {
  final String name;
  final String description;
  final IconData icon;

  const HealthGoal(this.name, this.description, this.icon);
}