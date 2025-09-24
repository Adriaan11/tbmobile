import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/floating_card.dart';
import '../widgets/gradient_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // final _formKey = GlobalKey<FormState>(); // TODO: Use for form validation if needed
  final _pageController = PageController();
  
  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Health Profile Controllers
  final _ageController = TextEditingController();
  String? _selectedActivityLevel;
  final List<String> _healthGoals = [];
  final List<String> _dietaryRestrictions = [];
  
  // Account Security Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _currentPage = 0;
  bool _agreedToTerms = false;

  final List<String> activityLevels = [
    'Sedentary (little or no exercise)',
    'Lightly active (1-3 days/week)',
    'Moderately active (3-5 days/week)',
    'Very active (6-7 days/week)',
    'Extra active (very hard exercise daily)',
  ];

  final List<String> availableHealthGoals = [
    'Weight Management',
    'Energy & Vitality',
    'Immune Support',
    'Muscle Building',
    'Stress Management',
    'Better Sleep',
    'Digestive Health',
    'Heart Health',
    'Brain Health',
    'Joint Support',
    'Skin Health',
    'General Wellness',
  ];

  final List<String> availableDietaryRestrictions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Dairy-Free',
    'Non-GMO Only',
    'Organic Only',
    'Keto',
    'Paleo',
    'No Soy',
    'No Nuts',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _handleSignup();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateHealthProfile();
      case 2:
        return _validateAccountSecurity();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name');
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name');
      return false;
    }
    if (!EmailValidator.validate(_emailController.text)) {
      _showError('Please enter a valid email');
      return false;
    }
    return true;
  }

  bool _validateHealthProfile() {
    if (_ageController.text.isEmpty) {
      _showError('Please enter your age');
      return false;
    }
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 13 || age > 120) {
      _showError('Please enter a valid age (13-120)');
      return false;
    }
    if (_selectedActivityLevel == null) {
      _showError('Please select your activity level');
      return false;
    }
    if (_healthGoals.isEmpty) {
      _showError('Please select at least one health goal');
      return false;
    }
    return true;
  }

  bool _validateAccountSecurity() {
    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (!_agreedToTerms) {
      _showError('Please agree to the terms and conditions');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  Future<void> _handleSignup() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text),
      activityLevel: _selectedActivityLevel,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppTheme.success,
          ),
        );
        // Navigate to home or onboarding
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.getTextPrimaryColor(context)),
          onPressed: _currentPage > 0 ? _previousPage : () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Container(
              width: index == _currentPage ? 24 : 8,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentPage 
                    ? AppTheme.getPrimaryColor(context) 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPersonalInfoPage(),
                  _buildHealthProfilePage(),
                  _buildAccountSecurityPage(),
                ],
              )),
            _buildNavigationButtons(),
          ],
        )),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    final textTheme = Theme.of(context).textTheme;
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final primary = AppTheme.getPrimaryColor(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: textTheme.headlineSmall?.copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s get to know you better',
              style: textTheme.bodyMedium?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedTextField(
                    label: 'First Name',
                    hint: 'e.g. Ava',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedTextField(
                    label: 'Last Name',
                    hint: 'e.g. Carter',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedTextField(
                    label: 'Email Address',
                    hint: 'you@tailorblend.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedTextField(
                    label: 'Phone Number (Optional)',
                    hint: 'Digits only',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              hoverScale: 1.0,
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your personal information is protected and will never be shared without your consent.',
                      style: textTheme.bodySmall?.copyWith(color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthProfilePage() {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final primary = AppTheme.getPrimaryColor(context);
    // Removed unused variable
    final secondary = AppTheme.getSecondaryColor(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Profile',
              style: textTheme.headlineSmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us personalize your nutrition',
              style: textTheme.bodyMedium?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedTextField(
                    label: 'Age',
                    hint: 'In years',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.cake_outlined,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activity Level',
                      style: textTheme.labelLarge?.copyWith(color: textPrimary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingCard(
                    glassmorphic: true,
                    hoverScale: 1.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      icon: Icon(Icons.expand_more, color: primary),
                      decoration: const InputDecoration(border: InputBorder.none),
                      hint: Text(
                        'Select activity level',
                        style: textTheme.bodyMedium?.copyWith(color: textSecondary),
                      ),
                      items: activityLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level, style: textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedActivityLevel = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Health Goals',
              style: textTheme.labelLarge?.copyWith(color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: textTheme.bodySmall?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableHealthGoals.map((goal) {
                final isSelected = _healthGoals.contains(goal);
                return ChoiceChip(
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _healthGoals.add(goal);
                      } else {
                        _healthGoals.remove(goal);
                      }
                    });
                  },
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: primary,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: primary.withValues(alpha: isSelected ? 0.2 : 0.18)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Dietary Preferences',
              style: textTheme.labelLarge?.copyWith(color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional - Select if applicable',
              style: textTheme.bodySmall?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableDietaryRestrictions.map((restriction) {
                final isSelected = _dietaryRestrictions.contains(restriction);
                return ChoiceChip(
                  label: Text(restriction),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _dietaryRestrictions.add(restriction);
                      } else {
                        _dietaryRestrictions.remove(restriction);
                      }
                    });
                  },
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: secondary,
                  backgroundColor: secondary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: secondary.withValues(alpha: isSelected ? 0.2 : 0.18)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSecurityPage() {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final primary = AppTheme.getPrimaryColor(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Your Account',
              style: textTheme.headlineSmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a strong password for your account',
              style: textTheme.bodyMedium?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedTextField(
                    label: 'Password',
                    hint: 'Use at least 8 characters',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordStrengthIndicator(),
                  const SizedBox(height: 20),
                  AnimatedTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              hoverScale: 1.0,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password requirements',
                    style: textTheme.labelLarge?.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirement('At least 8 characters',
                      _passwordController.text.length >= 8),
                  _buildRequirement('Contains uppercase letter',
                      _passwordController.text.contains(RegExp(r'[A-Z]'))),
                  _buildRequirement('Contains lowercase letter',
                      _passwordController.text.contains(RegExp(r'[a-z]'))),
                  _buildRequirement('Contains number',
                      _passwordController.text.contains(RegExp(r'[0-9]'))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: _agreedToTerms ? AppTheme.getPrimaryGradient(context) : null,
                      border: Border.all(
                        color: primary.withValues(alpha: _agreedToTerms ? 0 : 0.25),
                        width: 1.4,
                      ),
                      color: _agreedToTerms ? null : (AppTheme.isDarkMode(context)
                          ? AppTheme.surfaceAltDark.withValues(alpha: 0.85)
                          : AppTheme.surfaceAltLight.withValues(alpha: 0.9)),
                    ),
                    child: _agreedToTerms
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodySmall?.copyWith(color: textSecondary),
                        children: [
                          const TextSpan(text: 'I agree to TailorBlend\'s '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: textTheme.bodySmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: textTheme.bodySmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    Color strengthColor = Colors.grey;
    String strengthText = 'Weak';
    final trackColor = AppTheme.isDarkMode(context)
        ? AppTheme.surfaceAltDark.withValues(alpha: 0.6)
        : AppTheme.surfaceAltLight.withValues(alpha: 0.6);

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 0:
      case 1:
        strengthColor = AppTheme.error;
        strengthText = 'Weak';
        break;
      case 2:
      case 3:
        strengthColor = AppTheme.warning;
        strengthText = 'Medium';
        break;
      case 4:
      case 5:
        strengthColor = AppTheme.success;
        strengthText = 'Strong';
        break;
    }

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 5,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet
                ? AppTheme.success
                : AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? AppTheme.getTextPrimaryColor(context)
                  : AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final authService = Provider.of<AuthService>(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset / 2),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: FloatingCard(
                glassmorphic: true,
                hoverScale: 1.0,
                onTap: authService.isLoading ? null : _previousPage,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_left, color: AppTheme.getTextPrimaryColor(context), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppTheme.getTextPrimaryColor(context)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentPage > 0 ? 2 : 1,
            child: GradientButton(
              text: _currentPage < 2 ? 'Continue' : 'Create Account',
              icon: _currentPage < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
              isLoading: authService.isLoading,
              onPressed: authService.isLoading ? null : _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}
