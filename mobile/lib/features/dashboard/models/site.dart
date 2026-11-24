enum SiteStatus {
  online('online'),
  degraded('degraded'),
  offline('offline'),
  maintenance('maintenance');

  const SiteStatus(this.apiValue);

  final String apiValue;

  static SiteStatus fromApi(String? value) {
    return SiteStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => SiteStatus.offline,
    );
  }
}

class Site {
  const Site({
    required this.id,
    required this.name,
    required this.location,
    required this.capacityKw,
    required this.status,
    required this.todayKwh,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String location;
  final double capacityKw;
  final SiteStatus status;
  final double todayKwh;
  final DateTime createdAt;

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      capacityKw: (json['capacity_kw'] as num).toDouble(),
      status: SiteStatus.fromApi(json['status'] as String?),
      todayKwh: (json['today_kwh'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
