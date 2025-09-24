import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class AnimatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool autofocus;
  final bool showCounter;

  const AnimatedTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.showCounter = false,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  bool _hasError = false;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize color animation properly
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateBorderAnimation(BuildContext context) {
    final primaryColor = AppTheme.getPrimaryColor(context);
    final errorColor = AppTheme.error;
    final neutralColor = primaryColor.withValues(alpha: 0.1);

    _borderColorAnimation = ColorTween(
      begin: _hasError ? errorColor : neutralColor,
      end: _hasError ? errorColor : (_isFocused ? primaryColor : neutralColor),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textPrimaryColor = AppTheme.getTextPrimaryColor(context);
    final textSecondaryColor = AppTheme.getTextSecondaryColor(context);
    final backgroundColor = isDark ? AppTheme.cardDark : Colors.white;

    _updateBorderAnimation(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
            if (hasFocus) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _borderColorAnimation.value ?? Colors.transparent,
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  validator: (value) {
                    final result = widget.validator?.call(value);
                    setState(() {
                      _hasError = result != null;
                    });
                    return result;
                  },
                  enabled: widget.enabled,
                  maxLines: widget.isPassword ? 1 : widget.maxLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onChanged: widget.onChanged,
                  autofocus: widget.autofocus,
                  style: TextStyle(
                    fontSize: 16,
                    color: textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    labelStyle: TextStyle(
                      color: _isFocused ? primaryColor : textSecondaryColor,
                      fontSize: _isFocused ? 14 : 16,
                    ),
                    hintStyle: TextStyle(
                      color: textSecondaryColor.withValues(alpha: 0.5),
                      fontSize: 15,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: InputBorder.none,
                    counterText: widget.showCounter ? null : '',
                    prefixIcon: widget.prefixIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 20, right: 12),
                            child: Icon(
                              widget.prefixIcon,
                              color: _isFocused ? primaryColor : textSecondaryColor,
                              size: 22,
                            ),
                          )
                        : null,
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            padding: const EdgeInsets.only(right: 12),
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: textSecondaryColor,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ).animate().fadeIn(duration: 300.ms)
                        : widget.suffixIcon != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: widget.suffixIcon,
                              )
                            : null,
                  ),
                ),
              );
            },
          ),
        ),
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 20),
            child: Text(
              widget.validator?.call(widget.controller.text) ?? '',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 12,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.2, end: 0, duration: 200.ms)
              .shake(duration: 300.ms, hz: 3, offset: const Offset(2, 0)),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}