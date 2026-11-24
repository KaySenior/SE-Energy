import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../data/dashboard_repository.dart';
import '../models/metrics_summary.dart';
import '../widgets/error_view.dart';
import '../widgets/metric_card.dart';
import '../widgets/site_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.apiBaseUrl,
  });

  final DashboardRepository repository;
  final String apiBaseUrl;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.load();
  }

  void _reload() {
    setState(() {
      _future = widget.repository.load();
    });
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _future;
    } catch (_) {
      // The FutureBuilder renders the failure state.
    }
  }

  Future<void> _showApiInfo() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Base URL'),
            const SizedBox(height: 4),
            SelectableText(
              widget.apiBaseUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Override with --dart-define=API_BASE_URL=<url>',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: [
          IconButton(
            tooltip: 'API connection',
            onPressed: _showApiInfo,
            icon: const Icon(Icons.link),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: '${snapshot.error}',
              apiBaseUrl: widget.apiBaseUrl,
              onRetry: _reload,
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return ErrorView(
              message: 'The API returned no data.',
              apiBaseUrl: widget.apiBaseUrl,
              onRetry: _reload,
            );
          }
          return _DashboardBody(data: data, onRefresh: _refresh);
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.onRefresh});

  final DashboardData data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = data.metrics;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _GenerationHero(metrics: metrics),
          const SizedBox(height: 20),
          _MetricGrid(metrics: metrics),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Sites',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data.sites.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Updated ${_timeLabel(metrics.updatedAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.sites.isEmpty)
            const _EmptySites()
          else
            for (final (index, site) in data.sites.indexed) ...[
              if (index > 0) const SizedBox(height: 10),
              SiteTile(site: site),
            ],
        ],
      ),
    );
  }

  static String _timeLabel(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _GenerationHero extends StatelessWidget {
  const _GenerationHero({required this.metrics});

  final MetricsSummary metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gradientEnd = Color.lerp(scheme.primary, Colors.black, 0.22)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.solar_power, size: 18, color: scheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                'FLEET GENERATION TODAY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatNumber(metrics.todayKwh, decimals: 1),
            style: theme.textTheme.displaySmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'kWh delivered',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: metrics.onlineCount > 0
                        ? const Color(0xFF7CF2B0)
                        : const Color(0xFFFFC46B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${metrics.onlineCount} of ${metrics.siteCount} sites online',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final MetricsSummary metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns == 4 ? 1.9 : 1.7,
          children: [
            MetricCard(
              icon: Icons.bolt,
              label: 'Installed capacity',
              value: formatNumber(metrics.totalCapacityKw, decimals: 0),
              unit: 'kW',
            ),
            MetricCard(
              icon: Icons.apartment,
              label: 'Sites',
              value: formatNumber(metrics.siteCount),
            ),
            MetricCard(
              icon: Icons.wifi_tethering,
              label: 'Online now',
              value: formatNumber(metrics.onlineCount),
            ),
            MetricCard(
              icon: Icons.trending_up,
              label: 'Availability',
              value: metrics.siteCount == 0
                  ? '—'
                  : '${((metrics.onlineCount / metrics.siteCount) * 100).round()}',
              unit: metrics.siteCount == 0 ? null : '%',
            ),
          ],
        );
      },
    );
  }
}

class _EmptySites extends StatelessWidget {
  const _EmptySites();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.add_location_alt_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No sites yet. Register one through the API.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.energy_savings_leaf,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SE Energy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Fleet overview',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
