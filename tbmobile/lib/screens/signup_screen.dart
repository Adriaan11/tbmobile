import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_text_field.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
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
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s get to know you better',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'First Name',
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
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Last Name',
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
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email Address',
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
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Phone Number (Optional)',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.getPrimaryColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your personal information is protected and will never be shared without your consent.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextPrimaryColor(context).withValues(alpha: 0.8),
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

  Widget _buildHealthProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us personalize your nutrition',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.cake_outlined,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                ),
                hint: const Text('Select activity level'),
                items: activityLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      level,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Health Goals',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableHealthGoals.map((goal) {
                final isSelected = _healthGoals.contains(goal);
                return FilterChip(
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
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.getPrimaryColor(context),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.getPrimaryColor(context) : AppTheme.getTextSecondaryColor(context),
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.getPrimaryColor(context) : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Dietary Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional - Select if applicable',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableDietaryRestrictions.map((restriction) {
                final isSelected = _dietaryRestrictions.contains(restriction);
                return FilterChip(
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
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.getSecondaryColor(context).withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.getSecondaryColor(context),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.getSecondaryColor(context) : AppTheme.getTextSecondaryColor(context),
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.getSecondaryColor(context) : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSecurityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Your Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a strong password for your account',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Password',
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
            CustomTextField(
              label: 'Confirm Password',
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
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
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
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryLight,
                      ),
                      children: [
                        TextSpan(text: 'I agree to TailorBlend\'s '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                backgroundColor: Colors.grey[200],
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
            color: isMet ? AppTheme.success : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppTheme.textPrimaryLight : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final authService = Provider.of<AuthService>(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentPage > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: authService.isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authService.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentPage < 2 ? 'Continue' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}