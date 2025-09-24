import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/blend_wizard_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_card.dart';
import 'wizard_steps/step1_client_setup.dart';
import 'wizard_steps/step2_health_goals.dart';
import 'wizard_steps/step3_ingredients.dart';
import 'wizard_steps/step4_dosage_tuning.dart';
import 'wizard_steps/step5_review.dart';

class BlendCreationWizard extends StatefulWidget {
  const BlendCreationWizard({super.key});

  @override
  State<BlendCreationWizard> createState() => _BlendCreationWizardState();
}

class _BlendCreationWizardState extends State<BlendCreationWizard> {
  late PageController _pageController;
  late BlendWizardProvider _wizardProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _wizardProvider = BlendWizardProvider();
    _wizardProvider.addListener(_onStepChanged);
  }

  @override
  void dispose() {
    _wizardProvider.removeListener(_onStepChanged);
    _wizardProvider.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _wizardProvider.currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    
    return ChangeNotifierProvider.value(
      value: _wizardProvider,
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getSurfaceColor(context),
          elevation: 0,
          title: Text(
            'Create Personalized Blend',
            style: TextStyle(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.getTextPrimaryColor(context),
            ),
            onPressed: () {
              if (_wizardProvider.currentStep > 0) {
                _wizardProvider.previousStep();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              onPressed: () {
                _showExitConfirmation();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: _buildProgressIndicator(),
            ),
            // Wizard content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1ClientSetup(),
                  Step2HealthGoals(),
                  Step3Ingredients(),
                  Step4DosageTuning(),
                  Step5Review(),
                ],
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        final steps = [
          'Client & Setup',
          'Health Goals',
          'Ingredients',
          'Fine-tune',
          'Review',
        ];
        
        return Column(
          children: [
            Row(
              children: List.generate(steps.length, (index) {
                final isActive = index == provider.currentStep;
                final isCompleted = index < provider.currentStep;
                
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? AppTheme.getPrimaryColor(context)
                              : AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? AppTheme.getPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        final canProceed = _canProceed(provider);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (provider.currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ),
                ),
              if (provider.currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: canProceed ? () => _handleNext(provider) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    disabledBackgroundColor: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          provider.currentStep == 4 ? 'Create Blend' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canProceed(BlendWizardProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return provider.validateStep1();
      case 1:
        return provider.validateStep2();
      case 2:
        return provider.validateStep3();
      case 3:
        return provider.validateStep4();
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleNext(BlendWizardProvider provider) async {
    if (provider.currentStep == 4) {
      // Create the blend
      final authService = Provider.of<AuthService>(context, listen: false);
      final practitionerId = authService.currentUser?['userId'] ?? 1;
      
      final success = await provider.createBlend(practitionerId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blend created successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (provider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } else {
      // Prepare data for next step if needed
      if (provider.currentStep == 2) {
        await provider.loadIngredients();
      } else if (provider.currentStep == 3) {
        await provider.prepareReview();
      }
      
      provider.nextStep();
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text(
          'Exit Wizard?',
          style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
        ),
        content: Text(
          'Are you sure you want to exit? Your progress will be lost.',
          style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}