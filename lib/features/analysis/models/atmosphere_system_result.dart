class AtmosphereSystemResult {
  final double geometricAltitudeM;
  final double temperatureC;
  final double pressureHpa;
  final double relativeHumidityPercent;

  final double isaTemperatureC;
  final double isaPressureHpa;
  final double isaDensityKgM3;

  final double temperatureDeviationC;
  final double pressureDeviationHpa;
  final double pressureDeviationPercent;
  final double densityDeviationKgM3;
  final double densityDeviationPercent;

  final double saturationVaporPressureHpa;
  final double vaporPressureHpa;
  final double dryAirPartialPressureHpa;
  final double humidAirDensityKgM3;

  final double densityAltitudeM;
  final double densityAltitudeDifferenceM;

  final String atmosphereStatus;
  final bool isAtmosphereWithinSupportedLimits;

  const AtmosphereSystemResult({
    required this.geometricAltitudeM,
    required this.temperatureC,
    required this.pressureHpa,
    required this.relativeHumidityPercent,
    required this.isaTemperatureC,
    required this.isaPressureHpa,
    required this.isaDensityKgM3,
    required this.temperatureDeviationC,
    required this.pressureDeviationHpa,
    required this.pressureDeviationPercent,
    required this.densityDeviationKgM3,
    required this.densityDeviationPercent,
    required this.saturationVaporPressureHpa,
    required this.vaporPressureHpa,
    required this.dryAirPartialPressureHpa,
    required this.humidAirDensityKgM3,
    required this.densityAltitudeM,
    required this.densityAltitudeDifferenceM,
    required this.atmosphereStatus,
    required this.isAtmosphereWithinSupportedLimits,
  });
}
