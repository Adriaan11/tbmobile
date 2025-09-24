import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/blend.dart';
import '../../data/models/user.dart';
import '../../data/repositories/blend_repository.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/animated_background.dart';
import 'blend_creation_wizard.dart';
import 'client_list_screen.dart';

class PractitionerDashboard extends StatefulWidget {
  const PractitionerDashboard({super.key});

  @override
  State<PractitionerDashboard> createState() => _PractitionerDashboardState();
}

class _PractitionerDashboardState extends State<PractitionerDashboard> {
  final BlendRepository _blendRepository = BlendRepository();
  final ScrollController _scrollController = ScrollController();
  
  List<Blend> _recentBlends = [];
  bool _isLoading = true;
  int _totalClients = 0;
  int _totalBlends = 0;
  int _pendingSyncs = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?['id'] ?? 1;
    
    try {
      // Load recent blends
      final blends = await _blendRepository.getRecentBlends(userId: userId);
      
      // Load stats
      final allBlends = await _blendRepository.getBlendsForUser(userId, asPatient: false);
      final unsyncedBlends = await _blendRepository.getUnsyncedBlends();
      
      setState(() {
        _recentBlends = blends;
        _totalBlends = allBlends.length;
        _pendingSyncs = unsyncedBlends.length;
        _totalClients = 15; // TODO: Get from practitioner repository
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    
    return AnimatedBackground(
      scrollController: _scrollController,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Practitioner Dashboard'),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.sync),
                  if (_pendingSyncs > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$_pendingSyncs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _handleSync,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentBlendsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Clients',
            value: _totalClients.toString(),
            icon: Icons.people,
            color: AppTheme.getPrimaryColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Blends',
            value: _totalBlends.toString(),
            icon: Icons.science,
            color: AppTheme.getSecondaryColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Pending Sync',
            value: _pendingSyncs.toString(),
            icon: Icons.cloud_upload,
            color: _pendingSyncs > 0 ? AppTheme.warning : AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return FloatingCard(
      glassmorphic: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradientButton(
                text: 'Create Blend',
                icon: Icons.add,
                height: 48,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlendCreationWizard(),
                    ),
                  ).then((_) => _loadDashboardData());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientButton(
                text: 'My Clients',
                icon: Icons.people_outline,
                height: 48,
                outlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBlendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Blends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all blends
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_recentBlends.isEmpty)
          FloatingCard(
            glassmorphic: true,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 48,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No blends created yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first blend to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...

_recentBlends.map((blend) => _buildBlendCard(blend)),
      ],
    );
  }

  Widget _buildBlendCard(Blend blend) {
    final isDark = AppTheme.isDarkMode(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FloatingCard(
        glassmorphic: true,
        onTap: () {
          // Navigate to blend detail
        },
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryGradient(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.science,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blend.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${blend.ingredients?.length ?? 0} ingredients • ${blend.totalAmount?.toStringAsFixed(1) ?? '0'} g',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  if (blend.createdDate != null)
                    Text(
                      _formatDate(blend.createdDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                ],
              ),
            ),
            if (!blend.isSynced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 14,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warning,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleSync() {
    // TODO: Implement sync logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync functionality coming soon')),
    );
  }
}