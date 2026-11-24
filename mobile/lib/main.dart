import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/config/app_config.dart';
import 'features/dashboard/data/dashboard_repository.dart';

void main() {
  final config = AppConfig.resolve();
  final apiClient = ApiClient(baseUrl: config.apiBaseUrl);

  runApp(
    SEEnergyApp(
      repository: ApiDashboardRepository(apiClient: apiClient),
      apiBaseUrl: config.apiBaseUrl,
    ),
  );
}
