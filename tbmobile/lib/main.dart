import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';
import 'widgets/gradient_button.dart';
import 'widgets/floating_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  runApp(const TailorBlendApp());
}

class TailorBlendApp extends StatelessWidget {
  const TailorBlendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TailorBlend',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userName = authService.currentUser?['firstName'] ?? 'User';
    final isDark = AppTheme.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TailorBlend',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeIcon,
              color: AppTheme.getTextPrimaryColor(context),
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppTheme.getTextPrimaryColor(context),
            ),
            onPressed: () async {
              await authService.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Hero Card
              HeroCard(
                title: 'Welcome back, $userName!',
                subtitle: 'Your personalized nutrition journey continues',
                icon: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'TB',
                      style: TextStyle(
                        color: isDark ? AppTheme.backgroundDark : Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Action Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickActionCard(
                    context,
                    'Create Blend',
                    Icons.science,
                    AppTheme.primaryLight,
                    () {
                      // TODO: Navigate to blend creation
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    'My Blends',
                    Icons.inventory_2,
                    AppTheme.secondaryLight,
                    () {
                      // TODO: Navigate to my blends
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    'Health Goals',
                    Icons.track_changes,
                    AppTheme.accentLight,
                    () {
                      // TODO: Navigate to health goals
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    'Progress',
                    Icons.trending_up,
                    AppTheme.info,
                    () {
                      // TODO: Navigate to progress
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Daily Tip',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              
              const SizedBox(height: 16),
              
              InfoCard(
                title: 'Stay Hydrated',
                description: 'Remember to drink at least 8 glasses of water daily for optimal supplement absorption.',
                icon: Icons.water_drop,
                iconColor: AppTheme.info,
              ),
              
              const SizedBox(height: 24),
              
              // Main CTA Button
              GradientButton(
                text: 'Create Your Personalized Blend',
                icon: Icons.add_circle,
                onPressed: () {
                  // TODO: Navigate to supplement creation
                },
              ),
              
              const SizedBox(height: 24),
              
              // Theme Mode Display
              Center(
                child: FloatingCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.themeIcon,
                        color: AppTheme.getPrimaryColor(context),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Theme: ${themeProvider.themeDisplayName}',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return FloatingCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}