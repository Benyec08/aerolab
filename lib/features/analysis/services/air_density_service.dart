import 'dart:math';

class AirDensityService {
  double calculate({
    required double temperatureC,
    required double pressureHpa,
  }) {
    const double gasConstantForDryAir = 287.05;

    final double temperatureK = temperatureC + 273.15;
    final double pressurePa = pressureHpa * 100;

    return pressurePa / (gasConstantForDryAir * temperatureK);
  }

  double calculateWithAltitude({
    required double altitudeM,
    required double temperatureC,
  }) {
    const double seaLevelDensity = 1.225;
    const double scaleHeight = 8500;

    final double temperatureFactor = 288.15 / (temperatureC + 273.15);

    return seaLevelDensity * exp(-altitudeM / scaleHeight) * temperatureFactor;
  }
}