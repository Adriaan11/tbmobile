import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/blend_wizard_provider.dart';
import '../../../data/models/user.dart';
import '../../../data/models/base_mix.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/floating_card.dart';

class Step1ClientSetup extends StatefulWidget {
  const Step1ClientSetup({super.key});

  @override
  State<Step1ClientSetup> createState() => _Step1ClientSetupState();
}

class _Step1ClientSetupState extends State<Step1ClientSetup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<User> _searchResults = [];
  bool _isSearching = false;

  // Sample base mixes - in production, load from database
  final List<BaseMix> _baseMixes = [
    BaseMix(
      baseMixId: 1,
      name: 'Whey Protein Shake',
      type: 53,
      minQuantity: 20.0,
      maxQuantity: 40.0,
      isVegan: false,
    ),
    BaseMix(
      baseMixId: 2,
      name: 'Vegan Protein Shake',
      type: 53,
      minQuantity: 20.0,
      maxQuantity: 40.0,
      isVegan: true,
    ),
    BaseMix(
      baseMixId: 3,
      name: 'Energy Drink',
      type: 54,
      minQuantity: 10.0,
      maxQuantity: 25.0,
      isVegan: true,
    ),
    BaseMix(
      baseMixId: 4,
      name: 'Active Ingredients Only',
      type: 217,
      minQuantity: 5.0,
      maxQuantity: 15.0,
      isVegan: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BlendWizardProvider>(context, listen: false);
    _nameController.text = provider.blendName;
    _descriptionController.text = provider.description;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _searchClients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final provider = Provider.of<BlendWizardProvider>(context, listen: false);
      final results = await provider.searchClients(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlendWizardProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Client Selection'),
              const SizedBox(height: 16),
              _buildClientSearchField(provider),
              const SizedBox(height: 16),
              
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                _buildSearchResults(provider),
              
              if (provider.selectedClient != null)
                _buildSelectedClient(provider),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Blend Details'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Blend Name',
                hint: 'e.g., Morning Energy Boost',
                onChanged: provider.updateBlendName,
                icon: Icons.label_outline,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Brief description of the blend',
                onChanged: provider.updateDescription,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Base Mix Selection'),
              const SizedBox(height: 16),
              
              ..._baseMixes.map((baseMix) => _buildBaseMixOption(
                baseMix,
                provider.selectedBaseMix?.baseMixId == baseMix.baseMixId,
                () => provider.selectBaseMix(baseMix),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppTheme.getTextPrimaryColor(context),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildClientSearchField(BlendWizardProvider provider) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search Client',
        hintText: 'Enter name or email',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: provider.selectedClient != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  provider.selectClient(null);
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
              )
            : null,
      ),
      onChanged: (value) {
        _searchClients(value);
      },
    );
  }

  Widget _buildSearchResults(BlendWizardProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getPrimaryColor(context).withOpacity(0.2),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final client = _searchResults[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.getPrimaryColor(context).withOpacity(0.1),
              child: Text(
                client.firstName[0].toUpperCase(),
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('${client.firstName} ${client.lastName}'),
            subtitle: Text(client.email),
            onTap: () {
              provider.selectClient(client);
              _searchController.text = '${client.firstName} ${client.lastName}';
              setState(() => _searchResults = []);
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedClient(BlendWizardProvider provider) {
    final client = provider.selectedClient!;
    return FloatingCard(
      glassmorphic: true,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.getPrimaryColor(context),
            child: Text(
              client.firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${client.firstName} ${client.lastName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  client.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildBaseMixOption(BaseMix baseMix, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FloatingCard(
        glassmorphic: true,
        onTap: onTap,
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppTheme.getPrimaryColor(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        baseMix.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (baseMix.isVegan) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Vegan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Range: ${baseMix.rangeDisplay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
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
}