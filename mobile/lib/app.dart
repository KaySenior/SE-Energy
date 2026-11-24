import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

/// Root widget. Dependencies are injected so screens can be tested with fakes.
class SEEnergyApp extends StatelessWidget {
  const SEEnergyApp({
    super.key,
    required this.repository,
    required this.apiBaseUrl,
  });

  final DashboardRepository repository;
  final String apiBaseUrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SE Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: DashboardScreen(repository: repository, apiBaseUrl: apiBaseUrl),
    );
  }
}
