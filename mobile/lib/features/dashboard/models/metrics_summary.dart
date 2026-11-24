class MetricsSummary {
  const MetricsSummary({
    required this.siteCount,
    required this.onlineCount,
    required this.totalCapacityKw,
    required this.todayKwh,
    required this.updatedAt,
  });

  final int siteCount;
  final int onlineCount;
  final double totalCapacityKw;
  final double todayKwh;
  final DateTime updatedAt;

  factory MetricsSummary.fromJson(Map<String, dynamic> json) {
    return MetricsSummary(
      siteCount: json['site_count'] as int,
      onlineCount: json['online_count'] as int,
      totalCapacityKw: (json['total_capacity_kw'] as num).toDouble(),
      todayKwh: (json['today_kwh'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
