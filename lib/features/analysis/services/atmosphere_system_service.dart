import 'dart:math';

import '../models/atmosphere_system_result.dart';
import 'air_density_service.dart';

class AtmosphereSystemService {
  static const double _dryAirGasConstantJPerKgK = 287.05287;
  static const double _waterVaporGasConstantJPerKgK = 461.495;

  static const double _minimumSupportedAltitudeM = -500.0;
  static const double _maximumSupportedAltitudeM = 20000.0;

  final AirDensityService _airDensityService;

  AtmosphereSystemService({AirDensityService? airDensityService})
    : _airDensityService = airDensityService ?? AirDensityService();

  AtmosphereSystemResult calculate({
    required double altitudeM,
    required double temperatureC,
    required double pressureHpa,
    required double relativeHumidityPercent,
  }) {
    _validateInputs(
      altitudeM: altitudeM,
      temperatureC: temperatureC,
      pressureHpa: pressureHpa,
      relativeHumidityPercent: relativeHumidityPercent,
    );

    final isaAtmosphere = _airDensityService.calculateIsaAtmosphere(
      altitudeM: altitudeM,
    );

    final saturationVaporPressureHpa = _calculateSaturationVaporPressureHpa(
      temperatureC,
    );

    final vaporPressureHpa =
        saturationVaporPressureHpa * relativeHumidityPercent / 100.0;

    if (vaporPressureHpa >= pressureHpa) {
      throw ArgumentError(
        'Su buharı kısmi basıncı toplam atmosfer basıncından küçük olmalıdır.',
      );
    }

    final dryAirPartialPressureHpa = pressureHpa - vaporPressureHpa;
    final temperatureK = temperatureC + 273.15;

    final humidAirDensityKgM3 =
        (dryAirPartialPressureHpa * 100.0) /
            (_dryAirGasConstantJPerKgK * temperatureK) +
        (vaporPressureHpa * 100.0) /
            (_waterVaporGasConstantJPerKgK * temperatureK);

    final densityAltitudeM = _calculateDensityAltitudeM(humidAirDensityKgM3);

    final temperatureDeviationC = temperatureC - isaAtmosphere.temperatureC;
    final pressureDeviationHpa = pressureHpa - isaAtmosphere.pressureHpa;
    final pressureDeviationPercent =
        pressureDeviationHpa / isaAtmosphere.pressureHpa * 100.0;
    final densityDeviationKgM3 =
        humidAirDensityKgM3 - isaAtmosphere.densityKgM3;
    final densityDeviationPercent =
        densityDeviationKgM3 / isaAtmosphere.densityKgM3 * 100.0;
    final densityAltitudeDifferenceM = densityAltitudeM - altitudeM;

    return AtmosphereSystemResult(
      geometricAltitudeM: altitudeM,
      temperatureC: temperatureC,
      pressureHpa: pressureHpa,
      relativeHumidityPercent: relativeHumidityPercent,
      isaTemperatureC: isaAtmosphere.temperatureC,
      isaPressureHpa: isaAtmosphere.pressureHpa,
      isaDensityKgM3: isaAtmosphere.densityKgM3,
      temperatureDeviationC: temperatureDeviationC,
      pressureDeviationHpa: pressureDeviationHpa,
      pressureDeviationPercent: pressureDeviationPercent,
      densityDeviationKgM3: densityDeviationKgM3,
      densityDeviationPercent: densityDeviationPercent,
      saturationVaporPressureHpa: saturationVaporPressureHpa,
      vaporPressureHpa: vaporPressureHpa,
      dryAirPartialPressureHpa: dryAirPartialPressureHpa,
      humidAirDensityKgM3: humidAirDensityKgM3,
      densityAltitudeM: densityAltitudeM,
      densityAltitudeDifferenceM: densityAltitudeDifferenceM,
      atmosphereStatus: _evaluateAtmosphereStatus(
        densityAltitudeDifferenceM: densityAltitudeDifferenceM,
        temperatureDeviationC: temperatureDeviationC,
      ),
      isAtmosphereWithinSupportedLimits: true,
    );
  }

  // Buck denklemi; sıvı su ve buz üzerindeki doygunluk basıncı için
  // ayrı katsayılar kullanır. Sonuç hPa birimindedir.
  double _calculateSaturationVaporPressureHpa(double temperatureC) {
    if (temperatureC >= 0.0) {
      return 6.1121 *
          exp(
            (18.678 - temperatureC / 234.5) *
                (temperatureC / (257.14 + temperatureC)),
          );
    }

    return 6.1115 *
        exp(
          (23.036 - temperatureC / 333.7) *
              (temperatureC / (279.82 + temperatureC)),
        );
  }

  double _calculateDensityAltitudeM(double targetDensityKgM3) {
    final minimumDensity = _airDensityService.calculateIsaDensity(
      altitudeM: _maximumSupportedAltitudeM,
    );
    final maximumDensity = _airDensityService.calculateIsaDensity(
      altitudeM: _minimumSupportedAltitudeM,
    );

    if (targetDensityKgM3 >= maximumDensity) {
      return _minimumSupportedAltitudeM;
    }

    if (targetDensityKgM3 <= minimumDensity) {
      return _maximumSupportedAltitudeM;
    }

    var lowerAltitudeM = _minimumSupportedAltitudeM;
    var upperAltitudeM = _maximumSupportedAltitudeM;

    for (var iteration = 0; iteration < 80; iteration++) {
      final midpointAltitudeM = (lowerAltitudeM + upperAltitudeM) / 2.0;
      final midpointDensity = _airDensityService.calculateIsaDensity(
        altitudeM: midpointAltitudeM,
      );

      if (midpointDensity > targetDensityKgM3) {
        lowerAltitudeM = midpointAltitudeM;
      } else {
        upperAltitudeM = midpointAltitudeM;
      }
    }

    return (lowerAltitudeM + upperAltitudeM) / 2.0;
  }

  String _evaluateAtmosphereStatus({
    required double densityAltitudeDifferenceM,
    required double temperatureDeviationC,
  }) {
    if (densityAltitudeDifferenceM >= 2000 || temperatureDeviationC >= 25) {
      return 'Kritik Yoğunluk İrtifası';
    }

    if (densityAltitudeDifferenceM >= 1000 || temperatureDeviationC >= 15) {
      return 'Zorlu Atmosfer';
    }

    if (densityAltitudeDifferenceM >= 500 || temperatureDeviationC >= 8) {
      return 'Dikkat Gerektirir';
    }

    if (densityAltitudeDifferenceM <= -500) {
      return 'Yüksek Yoğunluk Avantajı';
    }

    return 'Normal Atmosfer';
  }

  void _validateInputs({
    required double altitudeM,
    required double temperatureC,
    required double pressureHpa,
    required double relativeHumidityPercent,
  }) {
    if (!altitudeM.isFinite ||
        altitudeM < _minimumSupportedAltitudeM ||
        altitudeM > _maximumSupportedAltitudeM) {
      throw ArgumentError.value(
        altitudeM,
        'altitudeM',
        'İrtifa -500 ile 20.000 metre arasında olmalıdır.',
      );
    }

    if (!temperatureC.isFinite || temperatureC <= -273.15) {
      throw ArgumentError.value(
        temperatureC,
        'temperatureC',
        'Sıcaklık mutlak sıfırdan büyük ve sonlu olmalıdır.',
      );
    }

    if (!pressureHpa.isFinite || pressureHpa <= 0) {
      throw ArgumentError.value(
        pressureHpa,
        'pressureHpa',
        'Basınç sıfırdan büyük ve sonlu olmalıdır.',
      );
    }

    if (!relativeHumidityPercent.isFinite ||
        relativeHumidityPercent < 0 ||
        relativeHumidityPercent > 100) {
      throw ArgumentError.value(
        relativeHumidityPercent,
        'relativeHumidityPercent',
        'Bağıl nem yüzde 0 ile 100 arasında olmalıdır.',
      );
    }
  }
}
