import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/floating_card.dart';
import '../widgets/gradient_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _rememberMe = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    // Skip validation for now - just login immediately
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Use email if provided, otherwise use a default
    final email = _emailController.text.isNotEmpty 
        ? _emailController.text.trim() 
        : 'user@tailorblend.com';

    setState(() => _isSubmitting = true);

    try {
      // Allow the button micro-interaction to be visible
      await Future.delayed(const Duration(milliseconds: 420));

      await authService.quickLogin(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to TailorBlend!'),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildForgotPasswordSheet(),
    );
  }

  Widget _buildForgotPasswordSheet() {
    final resetEmailController = TextEditingController();
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            FloatingCard(
              glassmorphic: true,
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: AnimatedTextField(
                label: 'Email Address',
                hint: 'you@tailorblend.com',
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
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
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Send Reset Link',
              icon: Icons.send_rounded,
              onPressed: () async {
                if (EmailValidator.validate(resetEmailController.text)) {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final result = await authService.resetPassword(
                    email: resetEmailController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor:
                            result['success'] ? AppTheme.success : AppTheme.error,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    return AnimatedBackground(
      scrollController: _scrollController,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryGradient(context),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.buttonShadow(primaryColor),
                        ),
                        child: const Center(
                          child: Text(
                            'TB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Welcome Back',
                        style: textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your personalized nutrition journey continues',
                        style: textTheme.bodyMedium?.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  duration: const Duration(milliseconds: 750),
                  delay: const Duration(milliseconds: 160),
                  child: FloatingCard(
                    glassmorphic: true,
                    borderRadius: 28,
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 20),
                          AnimatedTextField(
                            label: 'Password',
                            hint: 'Minimum 6 characters',
                            controller: _passwordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOutCubic,
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: _rememberMe
                                            ? AppTheme.getPrimaryGradient(context)
                                            : null,
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: _rememberMe ? 0 : 0.25,
                                          ),
                                          width: 1.4,
                                        ),
                                        color: _rememberMe
                                            ? null
                                            : AppTheme.getBackgroundColor(context).withValues(alpha: 0.6),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Remember me',
                                      style: textTheme.bodyMedium?.copyWith(color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _handleForgotPassword,
                                child: const Text('Forgot Password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: _isSubmitting ? 'Signing In…' : 'Sign In',
                            isLoading: _isSubmitting,
                            onPressed: _isSubmitting ? null : _handleLogin,
                            icon: Icons.arrow_forward_rounded,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        primaryColor.withValues(alpha: 0.18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: textTheme.labelMedium?.copyWith(color: textSecondary),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withValues(alpha: 0.18),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FloatingCard(
                            glassmorphic: true,
                            showBorder: false,
                            hoverScale: 1.02,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            onTap: () {
                              // TODO: Implement Google Sign In
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 28, color: primaryColor),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  duration: const Duration(milliseconds: 650),
                  delay: const Duration(milliseconds: 220),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(color: textSecondary),
                        children: [
                          const TextSpan(text: 'New to TailorBlend? '),
                          WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            alignment: PlaceholderAlignment.baseline,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text('Create Account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
