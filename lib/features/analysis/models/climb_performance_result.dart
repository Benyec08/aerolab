class ClimbPerformanceResult {
  final bool isApplicable;
  final double availablePropulsivePowerW;
  final double requiredLevelFlightPowerW;
  final double excessPowerW;
  final double rateOfClimbMs;
  final double rateOfClimbFpm;
  final double climbAngleDeg;
  final double timeTo1000MMinutes;
  final String status;
  final String message;

  const ClimbPerformanceResult({
    required this.isApplicable,
    required this.availablePropulsivePowerW,
    required this.requiredLevelFlightPowerW,
    required this.excessPowerW,
    required this.rateOfClimbMs,
    required this.rateOfClimbFpm,
    required this.climbAngleDeg,
    required this.timeTo1000MMinutes,
    required this.status,
    required this.message,
  });

  const ClimbPerformanceResult.notApplicable({
    this.status = 'Uygulanamaz',
    this.message =
        'Tırmanma performansı bu araç tipi veya mevcut girdiler için '
        'hesaplanamadı.',
  }) : isApplicable = false,
       availablePropulsivePowerW = 0.0,
       requiredLevelFlightPowerW = 0.0,
       excessPowerW = 0.0,
       rateOfClimbMs = 0.0,
       rateOfClimbFpm = 0.0,
       climbAngleDeg = 0.0,
       timeTo1000MMinutes = 0.0;

  bool get canClimb => isApplicable && rateOfClimbMs > 0.0;

  bool get hasPositiveExcessPower => excessPowerW > 0.0;

  Map<String, Object> toMap() {
    return {
      'isApplicable': isApplicable,
      'availablePropulsivePowerW': availablePropulsivePowerW,
      'requiredLevelFlightPowerW': requiredLevelFlightPowerW,
      'excessPowerW': excessPowerW,
      'rateOfClimbMs': rateOfClimbMs,
      'rateOfClimbFpm': rateOfClimbFpm,
      'climbAngleDeg': climbAngleDeg,
      'timeTo1000MMinutes': timeTo1000MMinutes,
      'status': status,
      'message': message,
    };
  }

  factory ClimbPerformanceResult.fromMap(Map<String, Object?> map) {
    return ClimbPerformanceResult(
      isApplicable: map['isApplicable']! as bool,
      availablePropulsivePowerW: (map['availablePropulsivePowerW']! as num)
          .toDouble(),
      requiredLevelFlightPowerW: (map['requiredLevelFlightPowerW']! as num)
          .toDouble(),
      excessPowerW: (map['excessPowerW']! as num).toDouble(),
      rateOfClimbMs: (map['rateOfClimbMs']! as num).toDouble(),
      rateOfClimbFpm: (map['rateOfClimbFpm']! as num).toDouble(),
      climbAngleDeg: (map['climbAngleDeg']! as num).toDouble(),
      timeTo1000MMinutes: (map['timeTo1000MMinutes']! as num).toDouble(),
      status: map['status']! as String,
      message: map['message']! as String,
    );
  }
}
