import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Palette - Professional Medical Theme
  static const Color primaryLight = Color(0xFF2C5282); // Deep Medical Blue - trust & authority
  static const Color secondaryLight = Color(0xFF4A7C7E); // Muted Sage - health & wellness
  static const Color accentLight = Color(0xFF6B8CAD); // Soft Steel Blue - professional highlight
  static const Color backgroundLight = Color(0xFFF8FAFB); // Cool White
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAltLight = Color(0xFFF5F7FA); // Subtle Gray Card
  static const Color textPrimaryLight = Color(0xFF1A202C); // Near Black - WCAG AAA
  static const Color textSecondaryLight = Color(0xFF4A5568); // Balanced Gray - WCAG AA
  static const Color outlineLight = Color(0xFFCBD5E0); // Soft Border Gray

  // Dark Palette - Professional Medical Theme
  static const Color primaryDark = Color(0xFF5B8DBE); // Brightened Medical Blue
  static const Color secondaryDark = Color(0xFF6FA1A3); // Soft Aqua - calming
  static const Color accentDark = Color(0xFF8FADC8); // Light Steel Blue - subtle highlights
  static const Color backgroundDark = Color(0xFF0F1419); // Medical Charcoal
  static const Color surfaceDark = Color(0xFF1A1F26); // Deep Navy Gray
  static const Color surfaceAltDark = Color(0xFF232830); // Elevated Surface
  static const Color cardDark = Color(0xFF1E232A); // Card Surface
  static const Color textPrimaryDark = Color(0xFFF7FAFC); // Off White - WCAG AAA
  static const Color textSecondaryDark = Color(0xFFA0AEC0); // Light Gray - WCAG AA
  static const Color outlineDark = Color(0xFF2D3748); // Subtle Border

  // Semantic Colors - Professional Tones
  static const Color success = Color(0xFF48BB78); // Muted Green
  static const Color error = Color(0xFFE53E3E); // Professional Red
  static const Color warning = Color(0xFFED8936); // Warm Orange
  static const Color info = Color(0xFF4299E1); // Trusted Blue

  // Gradients & Treatments - Subtle Professional
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [Color(0xFF2C5282), Color(0xFF3A5F8A), Color(0xFF4A7C7E)],
    stops: [0, 0.5, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF3A5F8A), Color(0xFF4A7993), Color(0xFF5B8DBE)],
    stops: [0, 0.5, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryLight, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF8FAFB), Color(0xFFFEFEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0F1419), Color(0xFF141922)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final LinearGradient glassGradientLight = LinearGradient(
    colors: [Colors.white.withValues(alpha: 0.88), Colors.white.withValues(alpha: 0.72)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassGradientDark = LinearGradient(
    colors: [const Color(0xFF1D2B28).withValues(alpha: 0.92), const Color(0xFF172622).withValues(alpha: 0.78)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: primaryLight.withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 4),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> buttonShadow(Color baseColor) => [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  // Typography
  static TextTheme getTextTheme(Color textColor) {
    final sans = GoogleFonts.plusJakartaSansTextTheme();
    final serif = GoogleFonts.playfairDisplayTextTheme();

    return sans
        .copyWith(
          displayLarge: serif.displayLarge?.copyWith(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.18,
            color: textColor,
          ),
          displayMedium: serif.displayMedium?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.22,
            color: textColor,
          ),
          displaySmall: serif.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            height: 1.3,
            color: textColor,
          ),
          headlineLarge: sans.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: textColor,
          ),
          headlineMedium: sans.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: textColor,
          ),
          headlineSmall: sans.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: textColor,
          ),
          titleLarge: sans.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: textColor,
          ),
          titleMedium: sans.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: textColor.withValues(alpha: 0.94),
          ),
          titleSmall: sans.titleSmall?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: textColor.withValues(alpha: 0.9),
          ),
          bodyLarge: sans.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.6,
            color: textColor.withValues(alpha: 0.94),
          ),
          bodyMedium: sans.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.6,
            color: textColor.withValues(alpha: 0.82),
          ),
          bodySmall: sans.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.55,
            letterSpacing: 0.2,
            color: textColor.withValues(alpha: 0.7),
          ),
          labelLarge: sans.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          labelMedium: sans.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: textColor.withValues(alpha: 0.8),
          ),
          labelSmall: sans.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: textColor.withValues(alpha: 0.7),
          ),
        )
        .apply(
          bodyColor: textColor,
          displayColor: textColor,
        );
  }

  static ThemeData lightTheme() {
    final textTheme = getTextTheme(textPrimaryLight);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      error: error,
      outline: outlineLight,
      tertiary: accentLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight, size: 22),
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceLight,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLight,
        modalBackgroundColor: surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryLight.withValues(alpha: 0.4);
            }
            return primaryLight;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shadowColor: WidgetStateProperty.all(primaryLight.withValues(alpha: 0.35)),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.12)),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          side: BorderSide(color: primaryLight.withValues(alpha: 0.32), width: 1.6),
          foregroundColor: primaryLight,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: textTheme.labelMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAltLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: textTheme.labelMedium?.copyWith(color: textSecondaryLight),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryLight.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: outlineLight.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: outlineLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryLight, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        actionTextColor: Colors.white,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: outlineLight.withValues(alpha: 0.4),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAltLight,
        selectedColor: primaryLight.withValues(alpha: 0.15),
        checkmarkColor: primaryLight,
        side: BorderSide(color: outlineLight.withValues(alpha: 0.5)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme() {
    final textTheme = getTextTheme(textPrimaryDark);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      error: error,
      outline: outlineDark,
      tertiary: accentDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 22),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        elevation: 14,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        modalBackgroundColor: surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryDark.withValues(alpha: 0.35);
            }
            return primaryDark;
          }),
          foregroundColor: WidgetStateProperty.all(backgroundDark),
          overlayColor: WidgetStateProperty.all(primaryDark.withValues(alpha: 0.2)),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          side: BorderSide(color: primaryDark.withValues(alpha: 0.35), width: 1.6),
          foregroundColor: primaryDark,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: textTheme.labelMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentDark,
          foregroundColor: backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAltDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: textTheme.labelMedium?.copyWith(color: textSecondaryDark),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryDark.withValues(alpha: 0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: outlineDark.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: outlineDark.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryDark, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAltDark,
        actionTextColor: primaryDark,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: outlineDark.withValues(alpha: 0.45),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAltDark,
        selectedColor: primaryDark.withValues(alpha: 0.18),
        checkmarkColor: primaryDark,
        side: BorderSide(color: outlineDark.withValues(alpha: 0.5)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 4),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Helper method to get current theme colors
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? primaryDark : primaryLight;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    return isDarkMode(context) ? secondaryDark : secondaryLight;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? backgroundDark : backgroundLight;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) ? surfaceDark : surfaceLight;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? textPrimaryDark : textPrimaryLight;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return isDarkMode(context) ? textSecondaryDark : textSecondaryLight;
  }
  
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return isDarkMode(context) ? primaryGradientDark : primaryGradientLight;
  }
  
  static LinearGradient getBackgroundGradient(BuildContext context) {
    return isDarkMode(context) ? backgroundGradientDark : backgroundGradientLight;
  }

  static LinearGradient getGlassGradient(BuildContext context) {
    return isDarkMode(context) ? glassGradientDark : glassGradientLight;
  }

  static List<BoxShadow> getCardShadow(BuildContext context) {
    return isDarkMode(context) ? cardShadowDark : cardShadowLight;
  }
}
