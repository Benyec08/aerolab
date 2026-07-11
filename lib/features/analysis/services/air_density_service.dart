import 'dart:math';

class AirDensityService {
  // ISA / U.S. Standard Atmosphere sabitleri
  static const double _seaLevelTemperatureK = 288.15;
  static const double _seaLevelPressurePa = 101325.0;

  static const double _gravityMS2 = 9.80665;
  static const double _gasConstantDryAir = 287.05287;

  // Troposfer sıcaklık gradyanı: -6.5 K / km
  static const double _troposphereLapseRateKPerM = -0.0065;

  // Troposfer üst sınırı (jeopotansiyel irtifa)
  static const double _troposphereLimitM = 11000.0;

  // Bu sürümde desteklenen ISA üst sınırı
  static const double _maximumSupportedAltitudeM = 20000.0;

  // Jeopotansiyel irtifa dönüşümünde kullanılan Dünya yarıçapı
  static const double _earthRadiusM = 6356766.0;

  /// Ölçülen sıcaklık ve basınçtan kuru hava yoğunluğu hesaplar.
  ///
  /// ρ = p / (R × T)
  ///
  /// [temperatureC] derece Celsius,
  /// [pressureHpa] hectopascal,
  /// sonuç kg/m³ birimindedir.
  double calculate({
    required double temperatureC,
    required double pressureHpa,
  }) {
    _validateTemperature(temperatureC);

    if (!pressureHpa.isFinite || pressureHpa <= 0) {
      throw ArgumentError.value(
        pressureHpa,
        'pressureHpa',
        'Basınç sıfırdan büyük ve sonlu olmalıdır.',
      );
    }

    final temperatureK = temperatureC + 273.15;
    final pressurePa = pressureHpa * 100.0;

    return pressurePa / (_gasConstantDryAir * temperatureK);
  }

  /// Girilen irtifadaki standart ISA hava yoğunluğunu hesaplar.
  ///
  /// Sıcaklık ve basınç tamamen ISA modelinden alınır.
  ///
  /// Sonuç kg/m³ birimindedir.
  double calculateIsaDensity({required double altitudeM}) {
    final atmosphere = calculateIsaAtmosphere(altitudeM: altitudeM);

    return atmosphere.densityKgM3;
  }

  /// Geriye dönük uyumluluk için korunmuştur.
  ///
  /// Basınç ISA modelinden, sıcaklık ise kullanıcı tarafından girilen
  /// gerçek ortam sıcaklığından alınır.
  ///
  /// Bu yöntem, standart basınç profili altında standart dışı sıcaklık
  /// koşullarını değerlendirmek için kullanılır.
  double calculateWithAltitude({
    required double altitudeM,
    required double temperatureC,
  }) {
    _validateTemperature(temperatureC);

    final pressurePa = calculateIsaPressurePa(altitudeM: altitudeM);

    final temperatureK = temperatureC + 273.15;

    return pressurePa / (_gasConstantDryAir * temperatureK);
  }

  /// Belirtilen irtifadaki ISA sıcaklık, basınç ve yoğunluk değerlerini
  /// birlikte döndürür.
  IsaAtmosphereResult calculateIsaAtmosphere({required double altitudeM}) {
    final geopotentialAltitudeM = _toGeopotentialAltitude(altitudeM);

    final temperatureK = _calculateIsaTemperatureKFromGeopotentialAltitude(
      geopotentialAltitudeM,
    );

    final pressurePa = _calculateIsaPressurePaFromGeopotentialAltitude(
      geopotentialAltitudeM,
    );

    final densityKgM3 = pressurePa / (_gasConstantDryAir * temperatureK);

    return IsaAtmosphereResult(
      geometricAltitudeM: altitudeM,
      geopotentialAltitudeM: geopotentialAltitudeM,
      temperatureC: temperatureK - 273.15,
      temperatureK: temperatureK,
      pressurePa: pressurePa,
      pressureHpa: pressurePa / 100.0,
      densityKgM3: densityKgM3,
    );
  }

  /// Belirtilen geometrik irtifadaki ISA sıcaklığını °C olarak hesaplar.
  double calculateIsaTemperatureC({required double altitudeM}) {
    final geopotentialAltitudeM = _toGeopotentialAltitude(altitudeM);

    return _calculateIsaTemperatureKFromGeopotentialAltitude(
          geopotentialAltitudeM,
        ) -
        273.15;
  }

  /// Belirtilen geometrik irtifadaki ISA basıncını Pa olarak hesaplar.
  double calculateIsaPressurePa({required double altitudeM}) {
    final geopotentialAltitudeM = _toGeopotentialAltitude(altitudeM);

    return _calculateIsaPressurePaFromGeopotentialAltitude(
      geopotentialAltitudeM,
    );
  }

  /// Belirtilen geometrik irtifadaki ISA basıncını hPa olarak hesaplar.
  double calculateIsaPressureHpa({required double altitudeM}) {
    return calculateIsaPressurePa(altitudeM: altitudeM) / 100.0;
  }

  double _calculateIsaTemperatureKFromGeopotentialAltitude(double altitudeM) {
    if (altitudeM <= _troposphereLimitM) {
      return _seaLevelTemperatureK + (_troposphereLapseRateKPerM * altitudeM);
    }

    // 11–20 km aralığında sıcaklık sabittir.
    return _temperatureAtTroposphereLimitK;
  }

  double _calculateIsaPressurePaFromGeopotentialAltitude(double altitudeM) {
    if (altitudeM <= _troposphereLimitM) {
      final temperatureK =
          _seaLevelTemperatureK + (_troposphereLapseRateKPerM * altitudeM);

      final exponent =
          -_gravityMS2 / (_troposphereLapseRateKPerM * _gasConstantDryAir);

      return _seaLevelPressurePa *
          pow(temperatureK / _seaLevelTemperatureK, exponent).toDouble();
    }

    // 11 km tabanındaki basınç
    final pressureAtTroposphereLimitPa = _calculateTroposphereLimitPressurePa();

    // 11–20 km aralığı izotermal katmandır.
    return pressureAtTroposphereLimitPa *
        exp(
          -_gravityMS2 *
              (altitudeM - _troposphereLimitM) /
              (_gasConstantDryAir * _temperatureAtTroposphereLimitK),
        );
  }

  double _calculateTroposphereLimitPressurePa() {
    final exponent =
        -_gravityMS2 / (_troposphereLapseRateKPerM * _gasConstantDryAir);

    return _seaLevelPressurePa *
        pow(
          _temperatureAtTroposphereLimitK / _seaLevelTemperatureK,
          exponent,
        ).toDouble();
  }

  double get _temperatureAtTroposphereLimitK {
    return _seaLevelTemperatureK +
        (_troposphereLapseRateKPerM * _troposphereLimitM);
  }

  /// Geometrik irtifayı jeopotansiyel irtifaya dönüştürür.
  ///
  /// h = (r × z) / (r + z)
  double _toGeopotentialAltitude(double geometricAltitudeM) {
    _validateAltitude(geometricAltitudeM);

    return (_earthRadiusM * geometricAltitudeM) /
        (_earthRadiusM + geometricAltitudeM);
  }

  void _validateAltitude(double altitudeM) {
    if (!altitudeM.isFinite) {
      throw ArgumentError.value(
        altitudeM,
        'altitudeM',
        'İrtifa sonlu bir sayı olmalıdır.',
      );
    }

    if (altitudeM < -500) {
      throw ArgumentError.value(
        altitudeM,
        'altitudeM',
        'Desteklenen minimum geometrik irtifa -500 metredir.',
      );
    }

    if (altitudeM > _maximumSupportedAltitudeM) {
      throw ArgumentError.value(
        altitudeM,
        'altitudeM',
        'Bu ISA modeli en fazla 20.000 metreyi destekler.',
      );
    }
  }

  void _validateTemperature(double temperatureC) {
    if (!temperatureC.isFinite) {
      throw ArgumentError.value(
        temperatureC,
        'temperatureC',
        'Sıcaklık sonlu bir sayı olmalıdır.',
      );
    }

    if (temperatureC <= -273.15) {
      throw ArgumentError.value(
        temperatureC,
        'temperatureC',
        'Sıcaklık mutlak sıfırdan büyük olmalıdır.',
      );
    }
  }
}

class IsaAtmosphereResult {
  final double geometricAltitudeM;
  final double geopotentialAltitudeM;

  final double temperatureC;
  final double temperatureK;

  final double pressurePa;
  final double pressureHpa;

  final double densityKgM3;

  const IsaAtmosphereResult({
    required this.geometricAltitudeM,
    required this.geopotentialAltitudeM,
    required this.temperatureC,
    required this.temperatureK,
    required this.pressurePa,
    required this.pressureHpa,
    required this.densityKgM3,
  });
}
