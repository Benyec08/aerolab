class WindSystemResult {
  final double windSpeedKmh;
  final double windSpeedMs;
  final String windDirection;

  final double headwindComponentMs;
  final double tailwindComponentMs;
  final double crosswindComponentMs;
  final String crosswindDirection;

  final double commandedAirspeedMs;
  final double effectiveAirspeedMs;
  final double estimatedGroundSpeedMs;

  final String windIntensityStatus;
  final String windSafetyStatus;
  final bool isWindWithinSupportedLimits;

  const WindSystemResult({
    required this.windSpeedKmh,
    required this.windSpeedMs,
    required this.windDirection,
    required this.headwindComponentMs,
    required this.tailwindComponentMs,
    required this.crosswindComponentMs,
    required this.crosswindDirection,
    required this.commandedAirspeedMs,
    required this.effectiveAirspeedMs,
    required this.estimatedGroundSpeedMs,
    required this.windIntensityStatus,
    required this.windSafetyStatus,
    required this.isWindWithinSupportedLimits,
  });
}
