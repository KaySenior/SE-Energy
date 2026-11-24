import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:se_energy_app/app.dart';
import 'package:se_energy_app/core/api/api_exception.dart';
import 'package:se_energy_app/features/dashboard/data/dashboard_repository.dart';
import 'package:se_energy_app/features/dashboard/models/metrics_summary.dart';
import 'package:se_energy_app/features/dashboard/models/site.dart';

class _FakeRepository implements DashboardRepository {
  _FakeRepository({this.fails = false});

  final bool fails;

  @override
  Future<DashboardData> load() async {
    if (fails) {
      throw const ApiException('Backend offline', statusCode: 503);
    }
    return DashboardData(
      metrics: MetricsSummary(
        siteCount: 2,
        onlineCount: 1,
        totalCapacityKw: 1450,
        todayKwh: 1234.5,
        updatedAt: DateTime(2026, 11, 24, 14, 32),
      ),
      sites: [
        Site(
          id: 'site-1',
          name: 'Rooftop Solar A',
          location: 'Accra, GH',
          capacityKw: 250,
          status: SiteStatus.online,
          todayKwh: 812.4,
          createdAt: DateTime(2026, 1, 15),
        ),
        Site(
          id: 'site-2',
          name: 'Harbour Storage',
          location: 'Tema, GH',
          capacityKw: 1200,
          status: SiteStatus.degraded,
          todayKwh: 422.1,
          createdAt: DateTime(2026, 2, 2),
        ),
      ],
    );
  }
}

Future<void> _pumpApp(WidgetTester tester, {bool fails = false}) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    SEEnergyApp(
      repository: _FakeRepository(fails: fails),
      apiBaseUrl: 'http://localhost:8000',
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders fleet metrics and sites', (tester) async {
    await _pumpApp(tester);

    expect(find.text('SE Energy'), findsOneWidget);
    expect(find.text('1,234.5'), findsOneWidget);
    expect(find.textContaining('1,450'), findsOneWidget);
    expect(find.text('Rooftop Solar A'), findsOneWidget);
    expect(find.text('Harbour Storage'), findsOneWidget);
    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.text('1 of 2 sites online'), findsOneWidget);
  });

  testWidgets('shows retry state when the API fails', (tester) async {
    await _pumpApp(tester, fails: true);

    expect(find.text('Cannot reach the API'), findsOneWidget);
    expect(find.text('Backend offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('http://localhost:8000'), findsOneWidget);
  });

  test('Site parses the FastAPI payload', () {
    final site = Site.fromJson({
      'id': 'abc',
      'name': 'Test Site',
      'location': 'Takoradi, GH',
      'capacity_kw': 42.5,
      'status': 'maintenance',
      'today_kwh': 0.0,
      'created_at': '2026-11-24T10:00:00Z',
    });

    expect(site.status, SiteStatus.maintenance);
    expect(site.capacityKw, 42.5);
    expect(site.createdAt.isUtc, isTrue);
  });
}
