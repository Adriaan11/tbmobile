import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class FloatingCard extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final defaultBackgroundColor = isDark ? AppTheme.cardDark : Colors.white;
    final shadows = customShadow ?? AppTheme.getCardShadow(context);
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBackgroundColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                width: 1,
              )
            : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
          highlightColor: AppTheme.getPrimaryColor(context).withValues(alpha: 0.05),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

    if (animate) {
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.backgroundDark : Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(
                      begin: -0.2,
                      end: 0,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: (isDark ? AppTheme.backgroundDark : Colors.white)
                        .withValues(alpha: 0.9),
                    height: 1.4,
                  ),
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
      backgroundColor: selected
          ? primaryColor.withValues(alpha: 0.1)
          : null,
      showBorder: selected,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? primaryColor).withValues(alpha: 0.1),
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