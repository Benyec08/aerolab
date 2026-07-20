class FlightEnvelopeResult {
  final bool isApplicable;
  final double minimumOperatingSpeedMs;
  final double stallSpeedMs;
  final double maneuveringSpeedMs;
  final double cruiseSpeedMs;
  final double maximumOperatingSpeedMs;
  final double positiveLimitLoadFactor;
  final double negativeLimitLoadFactor;
  final double maximumDynamicPressurePa;
  final bool isCruiseInsideEnvelope;
  final String status;
  final String message;

  const FlightEnvelopeResult({
    required this.isApplicable,
    required this.minimumOperatingSpeedMs,
    required this.stallSpeedMs,
    required this.maneuveringSpeedMs,
    required this.cruiseSpeedMs,
    required this.maximumOperatingSpeedMs,
    required this.positiveLimitLoadFactor,
    required this.negativeLimitLoadFactor,
    required this.maximumDynamicPressurePa,
    required this.isCruiseInsideEnvelope,
    required this.status,
    required this.message,
  });

  const FlightEnvelopeResult.notApplicable({
    this.status = 'Uygulanamaz',
    this.message =
        'Uçuş zarfı bu araç tipi veya mevcut girdiler için hesaplanamadı.',
  }) : isApplicable = false,
       minimumOperatingSpeedMs = 0.0,
       stallSpeedMs = 0.0,
       maneuveringSpeedMs = 0.0,
       cruiseSpeedMs = 0.0,
       maximumOperatingSpeedMs = 0.0,
       positiveLimitLoadFactor = 0.0,
       negativeLimitLoadFactor = 0.0,
       maximumDynamicPressurePa = 0.0,
       isCruiseInsideEnvelope = false;

  bool get hasValidSpeedRange =>
      isApplicable && maximumOperatingSpeedMs > minimumOperatingSpeedMs;

  Map<String, Object> toMap() {
    return {
      'isApplicable': isApplicable,
      'minimumOperatingSpeedMs': minimumOperatingSpeedMs,
      'stallSpeedMs': stallSpeedMs,
      'maneuveringSpeedMs': maneuveringSpeedMs,
      'cruiseSpeedMs': cruiseSpeedMs,
      'maximumOperatingSpeedMs': maximumOperatingSpeedMs,
      'positiveLimitLoadFactor': positiveLimitLoadFactor,
      'negativeLimitLoadFactor': negativeLimitLoadFactor,
      'maximumDynamicPressurePa': maximumDynamicPressurePa,
      'isCruiseInsideEnvelope': isCruiseInsideEnvelope,
      'status': status,
      'message': message,
    };
  }

  factory FlightEnvelopeResult.fromMap(Map<String, Object?> map) {
    return FlightEnvelopeResult(
      isApplicable: map['isApplicable']! as bool,
      minimumOperatingSpeedMs: (map['minimumOperatingSpeedMs']! as num)
          .toDouble(),
      stallSpeedMs: (map['stallSpeedMs']! as num).toDouble(),
      maneuveringSpeedMs: (map['maneuveringSpeedMs']! as num).toDouble(),
      cruiseSpeedMs: (map['cruiseSpeedMs']! as num).toDouble(),
      maximumOperatingSpeedMs: (map['maximumOperatingSpeedMs']! as num)
          .toDouble(),
      positiveLimitLoadFactor: (map['positiveLimitLoadFactor']! as num)
          .toDouble(),
      negativeLimitLoadFactor: (map['negativeLimitLoadFactor']! as num)
          .toDouble(),
      maximumDynamicPressurePa: (map['maximumDynamicPressurePa']! as num)
          .toDouble(),
      isCruiseInsideEnvelope: map['isCruiseInsideEnvelope']! as bool,
      status: map['status']! as String,
      message: map['message']! as String,
    );
  }
}
