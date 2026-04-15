/// Shortest-route payload returned by GET /api/v1/maps/route/shortest.
class RouteInfo {
  const RouteInfo({
    required this.distanceM,
    required this.distanceText,
    required this.durationSec,
    required this.durationText,
    required this.polyline,
    required this.start,
    required this.end,
    this.steps = const [],
    this.alternativesCount = 1,
  });

  final int distanceM;
  final String distanceText;
  final int durationSec;
  final String durationText;
  final String polyline;
  final RoutePoint start;
  final RoutePoint end;
  final List<RouteStep> steps;
  final int alternativesCount;

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
        distanceM: (json['distance_m'] ?? 0) as int,
        distanceText: (json['distance_text'] ?? '') as String,
        durationSec: (json['duration_sec'] ?? 0) as int,
        durationText: (json['duration_text'] ?? '') as String,
        polyline: (json['polyline'] ?? '') as String,
        start: RoutePoint.fromJson(
            Map<String, dynamic>.from(json['start'] as Map? ?? {})),
        end: RoutePoint.fromJson(
            Map<String, dynamic>.from(json['end'] as Map? ?? {})),
        steps: (json['steps'] as List? ?? [])
            .map((e) => RouteStep.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        alternativesCount: (json['alternatives_count'] ?? 1) as int,
      );
}

class RoutePoint {
  const RoutePoint({required this.lat, required this.lng, this.address = ''});
  final double lat;
  final double lng;
  final String address;

  factory RoutePoint.fromJson(Map<String, dynamic> j) => RoutePoint(
        lat: ((j['lat'] ?? 0) as num).toDouble(),
        lng: ((j['lng'] ?? 0) as num).toDouble(),
        address: (j['address'] ?? '') as String,
      );
}

class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.distanceM,
    required this.durationSec,
    required this.polyline,
  });
  final String instruction;
  final int distanceM;
  final int durationSec;
  final String polyline;

  factory RouteStep.fromJson(Map<String, dynamic> j) => RouteStep(
        instruction: (j['instruction'] ?? '') as String,
        distanceM: (j['distance_m'] ?? 0) as int,
        durationSec: (j['duration_sec'] ?? 0) as int,
        polyline: (j['polyline'] ?? '') as String,
      );
}
