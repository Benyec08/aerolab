class EnduranceRangeResult {
  final bool isApplicable;
  final double usableEnergyWh;
  final double cruisePowerW;
  final double enduranceHours;
  final double enduranceMinutes;
  final double cruiseSpeedMs;
  final double cruiseSpeedKmh;
  final double stillAirRangeKm;
  final double estimatedGroundSpeedMs;
  final double windAdjustedRangeKm;
  final String status;
  final String message;

  const EnduranceRangeResult({
    required this.isApplicable,
    required this.usableEnergyWh,
    required this.cruisePowerW,
    required this.enduranceHours,
    required this.enduranceMinutes,
    required this.cruiseSpeedMs,
    required this.cruiseSpeedKmh,
    required this.stillAirRangeKm,
    required this.estimatedGroundSpeedMs,
    required this.windAdjustedRangeKm,
    required this.status,
    required this.message,
  });

  const EnduranceRangeResult.notApplicable({
    this.status = 'Uygulanamaz',
    this.message =
        'Menzil ve havada kalış süresi bu araç tipi veya mevcut girdiler '
        'için hesaplanamadı.',
  }) : isApplicable = false,
       usableEnergyWh = 0.0,
       cruisePowerW = 0.0,
       enduranceHours = 0.0,
       enduranceMinutes = 0.0,
       cruiseSpeedMs = 0.0,
       cruiseSpeedKmh = 0.0,
       stillAirRangeKm = 0.0,
       estimatedGroundSpeedMs = 0.0,
       windAdjustedRangeKm = 0.0;

  bool get hasPositiveEndurance => isApplicable && enduranceHours > 0.0;

  bool get hasPositiveRange => isApplicable && windAdjustedRangeKm > 0.0;

  Map<String, Object> toMap() {
    return {
      'isApplicable': isApplicable,
      'usableEnergyWh': usableEnergyWh,
      'cruisePowerW': cruisePowerW,
      'enduranceHours': enduranceHours,
      'enduranceMinutes': enduranceMinutes,
      'cruiseSpeedMs': cruiseSpeedMs,
      'cruiseSpeedKmh': cruiseSpeedKmh,
      'stillAirRangeKm': stillAirRangeKm,
      'estimatedGroundSpeedMs': estimatedGroundSpeedMs,
      'windAdjustedRangeKm': windAdjustedRangeKm,
      'status': status,
      'message': message,
    };
  }

  factory EnduranceRangeResult.fromMap(Map<String, Object?> map) {
    return EnduranceRangeResult(
      isApplicable: map['isApplicable']! as bool,
      usableEnergyWh: (map['usableEnergyWh']! as num).toDouble(),
      cruisePowerW: (map['cruisePowerW']! as num).toDouble(),
      enduranceHours: (map['enduranceHours']! as num).toDouble(),
      enduranceMinutes: (map['enduranceMinutes']! as num).toDouble(),
      cruiseSpeedMs: (map['cruiseSpeedMs']! as num).toDouble(),
      cruiseSpeedKmh: (map['cruiseSpeedKmh']! as num).toDouble(),
      stillAirRangeKm: (map['stillAirRangeKm']! as num).toDouble(),
      estimatedGroundSpeedMs: (map['estimatedGroundSpeedMs']! as num)
          .toDouble(),
      windAdjustedRangeKm: (map['windAdjustedRangeKm']! as num).toDouble(),
      status: map['status']! as String,
      message: map['message']! as String,
    );
  }
}
