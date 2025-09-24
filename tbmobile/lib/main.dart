import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/practitioner/practitioner_dashboard.dart';
import 'utils/app_theme.dart';
import 'widgets/gradient_button.dart';
import 'widgets/floating_card.dart';
import 'widgets/animated_background.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userName = authService.currentUser?['firstName'] ?? 'User';
    final isDark = AppTheme.isDarkMode(context);

    return AnimatedBackground(
      scrollController: _scrollController,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                    final translate = (-offset * 0.08).clamp(-48.0, 0.0);
                    return Transform.translate(
                      offset: Offset(0, translate),
                      child: child,
                    );
                  },
                  child: HeroCard(
                    title: 'Welcome back, $userName!',
                    subtitle: 'Your personalized nutrition journey continues',
                    icon: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: AppTheme.secondaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'TB',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                        ),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                ),

                const SizedBox(height: 16),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _isLoading
                      ? _buildQuickActionsSkeleton(context)
                      : _buildQuickActionsGrid(context),
                ),

                const SizedBox(height: 32),

                Text(
                  'Daily Tip',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                ),

                const SizedBox(height: 16),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  child: _isLoading
                      ? _buildInfoCardSkeleton(context)
                      : InfoCard(
                          title: 'Stay Hydrated',
                          description: 'Remember to drink at least 8 glasses of water daily for optimal supplement absorption.',
                          icon: Icons.water_drop,
                          iconColor: AppTheme.info,
                        ),
                ),

                const SizedBox(height: 24),

                GradientButton(
                  text: 'Create Your Personalized Blend',
                  icon: Icons.add_circle,
                  onPressed: () {
                    // TODO: Navigate to supplement creation
                  },
                ),

                const SizedBox(height: 24),

                Center(
                  child: FloatingCard(
                    glassmorphic: true,
                    hoverScale: 1.02,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          themeProvider.themeIcon,
                          color: AppTheme.getPrimaryColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Theme: ${themeProvider.themeDisplayName}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppTheme.getTextSecondaryColor(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      (
        'Practitioner Mode',
        Icons.medical_services,
        AppTheme.primaryLight,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PractitionerDashboard(),
            ),
          );
        },
      ),
      (
        'My Blends',
        Icons.inventory_2,
        AppTheme.secondaryLight,
        () {
          // TODO: Navigate to my blends
        },
      ),
      (
        'Health Goals',
        Icons.track_changes,
        AppTheme.accentLight,
        () {
          // TODO: Navigate to health goals
        },
      ),
      (
        'Progress',
        Icons.trending_up,
        AppTheme.info,
        () {
          // TODO: Navigate to progress
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: actions.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickActionCard(
          context,
          action.$1,
          action.$2,
          action.$3,
          action.$4,
        );
      },
    );
  }

  Widget _buildQuickActionsSkeleton(BuildContext context) {
    final baseColor = AppTheme.getPrimaryColor(context).withValues(alpha: 0.08);
    final highlight = AppTheme.getPrimaryColor(context).withValues(alpha: 0.22);

    return IgnorePointer(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlight,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            return FloatingCard(
              glassmorphic: true,
              hoverScale: 1.0,
              onTap: null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCardSkeleton(BuildContext context) {
    final baseColor = AppTheme.getPrimaryColor(context).withValues(alpha: 0.08);
    final highlight = AppTheme.getPrimaryColor(context).withValues(alpha: 0.2);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlight,
      child: FloatingCard(
        glassmorphic: true,
        hoverScale: 1.0,
        onTap: null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = AppTheme.isDarkMode(context);
    final textColor = AppTheme.getTextPrimaryColor(context);

    return FloatingCard(
      onTap: onTap,
      glassmorphic: true,
      hoverScale: 1.04,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.85),
                  color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tailored shortcuts to move faster',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.getTextSecondaryColor(context)),
          ),
        ],
      ),
    );
  }
}
