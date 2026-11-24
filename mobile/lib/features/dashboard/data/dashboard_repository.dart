import '../../../core/api/api_client.dart';
import '../models/metrics_summary.dart';
import '../models/site.dart';

class DashboardData {
  const DashboardData({required this.metrics, required this.sites});

  final MetricsSummary metrics;
  final List<Site> sites;
}

abstract interface class DashboardRepository {
  Future<DashboardData> load();
}

/// Loads the dashboard from the FastAPI backend.
class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<DashboardData> load() async {
    final responses = await Future.wait([
      apiClient.getJson('/api/v1/metrics/summary'),
      apiClient.getJson('/api/v1/sites'),
    ]);

    final metrics = MetricsSummary.fromJson(
      responses[0] as Map<String, dynamic>,
    );
    final sites = (responses[1] as List<dynamic>)
        .map((item) => Site.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return DashboardData(metrics: metrics, sites: sites);
  }
}
