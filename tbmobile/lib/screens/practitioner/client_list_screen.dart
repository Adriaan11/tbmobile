import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('My Clients'),
      ),
      body: const Center(
        child: Text('Client List - Coming Soon'),
      ),
    );
  }
}