import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class BlendCreationScreen extends StatefulWidget {
  const BlendCreationScreen({super.key});

  @override
  State<BlendCreationScreen> createState() => _BlendCreationScreenState();
}

class _BlendCreationScreenState extends State<BlendCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Create New Blend'),
      ),
      body: const Center(
        child: Text('Blend Creation Wizard - Coming Soon'),
      ),
    );
  }
}