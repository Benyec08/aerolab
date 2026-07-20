class GlidePerformanceResult {
  final bool isApplicable;
  final double bestGlideRatio;
  final double bestGlideSpeedMs;
  final double bestGlideSpeedKmh;
  final double sinkRateMs;
  final double glideAngleDeg;
  final double glideDistanceFrom1000M;
  final double glideTimeFrom1000MMinutes;
  final String status;
  final String message;

  const GlidePerformanceResult({
    required this.isApplicable,
    required this.bestGlideRatio,
    required this.bestGlideSpeedMs,
    required this.bestGlideSpeedKmh,
    required this.sinkRateMs,
    required this.glideAngleDeg,
    required this.glideDistanceFrom1000M,
    required this.glideTimeFrom1000MMinutes,
    required this.status,
    required this.message,
  });

  const GlidePerformanceResult.notApplicable({
    this.status = 'Uygulanamaz',
    this.message =
        'Süzülme performansı bu araç tipi veya mevcut girdiler için '
        'hesaplanamadı.',
  }) : isApplicable = false,
       bestGlideRatio = 0.0,
       bestGlideSpeedMs = 0.0,
       bestGlideSpeedKmh = 0.0,
       sinkRateMs = 0.0,
       glideAngleDeg = 0.0,
       glideDistanceFrom1000M = 0.0,
       glideTimeFrom1000MMinutes = 0.0;

  bool get canGlide => isApplicable && bestGlideRatio > 0.0 && sinkRateMs > 0.0;

  Map<String, Object> toMap() {
    return {
      'isApplicable': isApplicable,
      'bestGlideRatio': bestGlideRatio,
      'bestGlideSpeedMs': bestGlideSpeedMs,
      'bestGlideSpeedKmh': bestGlideSpeedKmh,
      'sinkRateMs': sinkRateMs,
      'glideAngleDeg': glideAngleDeg,
      'glideDistanceFrom1000M': glideDistanceFrom1000M,
      'glideTimeFrom1000MMinutes': glideTimeFrom1000MMinutes,
      'status': status,
      'message': message,
    };
  }

  factory GlidePerformanceResult.fromMap(Map<String, Object?> map) {
    return GlidePerformanceResult(
      isApplicable: map['isApplicable']! as bool,
      bestGlideRatio: (map['bestGlideRatio']! as num).toDouble(),
      bestGlideSpeedMs: (map['bestGlideSpeedMs']! as num).toDouble(),
      bestGlideSpeedKmh: (map['bestGlideSpeedKmh']! as num).toDouble(),
      sinkRateMs: (map['sinkRateMs']! as num).toDouble(),
      glideAngleDeg: (map['glideAngleDeg']! as num).toDouble(),
      glideDistanceFrom1000M: (map['glideDistanceFrom1000M']! as num)
          .toDouble(),
      glideTimeFrom1000MMinutes: (map['glideTimeFrom1000MMinutes']! as num)
          .toDouble(),
      status: map['status']! as String,
      message: map['message']! as String,
    );
  }
}
