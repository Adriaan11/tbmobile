import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class FloatingCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final double borderRadius;
  final bool showBorder;
  final List<BoxShadow>? customShadow;
  final VoidCallback? onTap;
  final bool animate;
  final bool glassmorphic;
  final double? hoverScale;

  const FloatingCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = 20,
    this.showBorder = true,
    this.customShadow,
    this.onTap,
    this.animate = true,
    this.glassmorphic = false,
    this.hoverScale,
  });

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> {
  bool _isPressed = false;
  bool _isHovered = false;
  double _targetScale = 1.0;

  double get _hoverScale => widget.hoverScale ?? 1.02;

  void _animateTo(double value) {
    if (_targetScale == value) return;
    setState(() => _targetScale = value);
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _isPressed = true;
      _animateTo(0.96);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _isPressed = false;
      _animateTo(_isHovered ? _hoverScale : 1.0);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _isPressed = false;
      _animateTo(_isHovered ? _hoverScale : 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final defaultBackgroundColor = isDark ? AppTheme.surfaceAltDark : AppTheme.surfaceAltLight;
    final shadows = widget.customShadow ?? AppTheme.getCardShadow(context);
    final gradient = widget.gradient ?? (widget.glassmorphic ? AppTheme.getGlassGradient(context) : null);

    Widget card = MouseRegion(
      onEnter: (_) {
        if (widget.onTap != null) {
          _isHovered = true;
          if (!_isPressed) {
            _animateTo(_hoverScale);
          }
        }
      },
      onExit: (_) {
        if (widget.onTap != null) {
          _isHovered = false;
          if (!_isPressed) {
            _animateTo(1.0);
          }
        }
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: null,
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: _targetScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: gradient == null ? (widget.backgroundColor ?? defaultBackgroundColor) : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.showBorder
                ? Border.all(
                    color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.06),
                    width: widget.glassmorphic ? 0.6 : 0.8,
                  )
                : null,
              boxShadow: shadows,
              backgroundBlendMode: widget.glassmorphic ? BlendMode.overlay : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.05),
                highlightColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.02),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 220),
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.animate) {
      return card
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.easeOutCubic,
          );
    }
    return card;
  }
}

class HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final double height;
  final bool animate;

  const HeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.gradient,
    this.onTap,
    this.height = 160,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final defaultGradient = AppTheme.getPrimaryGradient(context);
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.headlineSmall?.copyWith(
      color: isDark ? AppTheme.backgroundDark : Colors.white,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      color: (isDark ? AppTheme.backgroundDark : Colors.white).withValues(alpha: 0.95),
      height: 1.4,
      fontWeight: FontWeight.w500,
    );

    return FloatingCard(
      height: height,
      gradient: gradient ?? defaultGradient,
      onTap: onTap,
      animate: animate,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: titleStyle,
                ).animate().fadeIn(delay: 200.ms).slideX(
                      begin: -0.2,
                      end: 0,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: subtitleStyle,
                ).animate().fadeIn(delay: 300.ms).slideX(
                      begin: -0.2,
                      end: 0,
                      duration: 500.ms,
                    ),
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 20),
            icon!.animate().fadeIn(delay: 400.ms).scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
          ],
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool selected;

  const InfoCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    
    return FloatingCard(
      onTap: onTap,
      glassmorphic: !selected,
      hoverScale: selected ? 1.0 : 1.02,
      backgroundColor: selected
          ? primaryColor.withValues(alpha: 0.08)
          : null,
      showBorder: selected,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? primaryColor).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor ?? primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (selected)
            Icon(
              Icons.check_circle,
              color: primaryColor,
              size: 24,
            ),
        ],
      ),
    );
  }
}
