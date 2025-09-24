import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_preference';
  
  ThemeType _themeType = ThemeType.system;
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeType get themeType => _themeType;
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeType = ThemeType.light;
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeType = ThemeType.dark;
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeType = ThemeType.system;
          _themeMode = ThemeMode.system;
      }
    }
    
    _updateSystemUI();
    notifyListeners();
  }

  Future<void> setThemeType(ThemeType type) async {
    _themeType = type;
    
    switch (type) {
      case ThemeType.light:
        _themeMode = ThemeMode.light;
        break;
      case ThemeType.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeType.system:
        _themeMode = ThemeMode.system;
        break;
    }
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, type.toString().split('.').last);
    
    _updateSystemUI();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeType == ThemeType.light) {
      await setThemeType(ThemeType.dark);
    } else if (_themeType == ThemeType.dark) {
      await setThemeType(ThemeType.light);
    } else {
      // If system theme, toggle based on current appearance
      if (isDarkMode) {
        await setThemeType(ThemeType.light);
      } else {
        await setThemeType(ThemeType.dark);
      }
    }
  }

  void _updateSystemUI() {
    final brightness = isDarkMode ? Brightness.light : Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: brightness,
      statusBarColor: Colors.transparent,
    );
    
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  // Get display name for current theme
  String get themeDisplayName {
    switch (_themeType) {
      case ThemeType.light:
        return 'Light';
      case ThemeType.dark:
        return 'Dark';
      case ThemeType.system:
        return 'System';
    }
  }

  // Get icon for current theme
  IconData get themeIcon {
    switch (_themeType) {
      case ThemeType.light:
        return Icons.light_mode;
      case ThemeType.dark:
        return Icons.dark_mode;
      case ThemeType.system:
        return Icons.brightness_auto;
    }
  }
}