class Environment {
  final double altitudeM;
  final double temperatureC;
  final double pressureHpa;
  final double humidityPercent;
  final double windSpeedKmh;
  final String windDirection;

  const Environment({
    required this.altitudeM,
    required this.temperatureC,
    required this.pressureHpa,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.windDirection,
  });
}