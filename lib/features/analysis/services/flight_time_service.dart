/*
====================================================================

Project
AeroLab

Module
Energy & Endurance Engine

File
flight_time_service.dart

Description

Bu servis batarya kapasitesi, nominal voltaj ve ortalama elektriksel
güç tüketimine göre tahmini uçuş süresini hesaplar.

Model şu etkileri destekler:

- Güvenlik rezervi
- Batarya sağlık oranı
- Sıcaklık kaynaklı kapasite düzeltmesi
- Yük kaynaklı kapasite düzeltmesi

Not:

Bu servis henüz hücre bazlı zaman bağımlı deşarj eğrisi,
iç direnç ve voltaj çökmesi simülasyonu yapmaz.

====================================================================
*/

class FlightTimeService {
  static const double defaultReserveFraction = 0.15;
  static const double defaultBatteryHealth = 1.0;
  static const double defaultTemperatureFactor = 1.0;
  static const double defaultLoadFactor = 1.0;

  /// Mevcut AnalysisService çağrılarıyla uyumluluğu koruyan metot.
  ///
  /// Varsayılan olarak nominal kapasitenin %15'i güvenlik rezervi
  /// olarak bırakılır. Böylece kullanılabilir kapasite %85 olur.
  double calculateMinutes({
    required double batteryCapacityMah,
    required double batteryVoltageV,
    required double averagePowerConsumptionW,
    double reserveFraction = defaultReserveFraction,
    double batteryHealth = defaultBatteryHealth,
    double temperatureFactor = defaultTemperatureFactor,
    double loadFactor = defaultLoadFactor,
  }) {
    return calculateDetailed(
      batteryCapacityMah: batteryCapacityMah,
      batteryVoltageV: batteryVoltageV,
      averagePowerConsumptionW: averagePowerConsumptionW,
      reserveFraction: reserveFraction,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
      loadFactor: loadFactor,
    ).estimatedFlightTimeMinutes;
  }

  /// Uçuş süresiyle birlikte ara enerji değerlerini de döndürür.
  FlightTimeResult calculateDetailed({
    required double batteryCapacityMah,
    required double batteryVoltageV,
    required double averagePowerConsumptionW,
    double reserveFraction = defaultReserveFraction,
    double batteryHealth = defaultBatteryHealth,
    double temperatureFactor = defaultTemperatureFactor,
    double loadFactor = defaultLoadFactor,
  }) {
    _validateInputs(
      batteryCapacityMah: batteryCapacityMah,
      batteryVoltageV: batteryVoltageV,
      averagePowerConsumptionW: averagePowerConsumptionW,
      reserveFraction: reserveFraction,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
      loadFactor: loadFactor,
    );

    //--------------------------------------------------------------
    // 1. mAh → Ah dönüşümü
    //--------------------------------------------------------------

    final nominalCapacityAh = batteryCapacityMah / 1000.0;

    //--------------------------------------------------------------
    // 2. Nominal batarya enerjisi
    //
    // E_nominal = Capacity(Ah) × Voltage(V)
    //--------------------------------------------------------------

    final nominalEnergyWh = nominalCapacityAh * batteryVoltageV;

    //--------------------------------------------------------------
    // 3. Kullanılabilir kapasite oranı
    //
    // usableFraction = 1 - reserveFraction
    //--------------------------------------------------------------

    final usableCapacityFraction = 1.0 - reserveFraction;

    //--------------------------------------------------------------
    // 4. Efektif enerji düzeltmeleri
    //
    // E_effective =
    // E_nominal
    // × usableCapacityFraction
    // × batteryHealth
    // × temperatureFactor
    // × loadFactor
    //--------------------------------------------------------------

    final effectiveEnergyWh =
        nominalEnergyWh *
        usableCapacityFraction *
        batteryHealth *
        temperatureFactor *
        loadFactor;

    //--------------------------------------------------------------
    // 5. Uçuş süresi
    //
    // Time(h) = Effective Energy(Wh) / Average Power(W)
    //--------------------------------------------------------------

    final flightTimeHours = effectiveEnergyWh / averagePowerConsumptionW;

    final flightTimeMinutes = flightTimeHours * 60.0;

    //--------------------------------------------------------------
    // 6. Ortalama batarya akımı
    //
    // I(A) = P(W) / V(V)
    //--------------------------------------------------------------

    final estimatedAverageCurrentA = averagePowerConsumptionW / batteryVoltageV;

    return FlightTimeResult(
      nominalCapacityAh: nominalCapacityAh,
      nominalEnergyWh: nominalEnergyWh,
      effectiveEnergyWh: effectiveEnergyWh,
      usableCapacityFraction: usableCapacityFraction,
      estimatedAverageCurrentA: estimatedAverageCurrentA,
      estimatedFlightTimeMinutes: flightTimeMinutes,
    );
  }

  void _validateInputs({
    required double batteryCapacityMah,
    required double batteryVoltageV,
    required double averagePowerConsumptionW,
    required double reserveFraction,
    required double batteryHealth,
    required double temperatureFactor,
    required double loadFactor,
  }) {
    if (!batteryCapacityMah.isFinite || batteryCapacityMah <= 0) {
      throw ArgumentError.value(
        batteryCapacityMah,
        'batteryCapacityMah',
        'Batarya kapasitesi sıfırdan büyük olmalıdır.',
      );
    }

    if (!batteryVoltageV.isFinite || batteryVoltageV <= 0) {
      throw ArgumentError.value(
        batteryVoltageV,
        'batteryVoltageV',
        'Batarya voltajı sıfırdan büyük olmalıdır.',
      );
    }

    if (!averagePowerConsumptionW.isFinite || averagePowerConsumptionW <= 0) {
      throw ArgumentError.value(
        averagePowerConsumptionW,
        'averagePowerConsumptionW',
        'Ortalama güç tüketimi sıfırdan büyük olmalıdır.',
      );
    }

    if (!reserveFraction.isFinite ||
        reserveFraction < 0 ||
        reserveFraction >= 1) {
      throw ArgumentError.value(
        reserveFraction,
        'reserveFraction',
        'Rezerv oranı 0 dahil, 1 hariç aralıkta olmalıdır.',
      );
    }

    _validateCorrectionFactor(
      value: batteryHealth,
      parameterName: 'batteryHealth',
      description: 'Batarya sağlık oranı',
    );

    _validateCorrectionFactor(
      value: temperatureFactor,
      parameterName: 'temperatureFactor',
      description: 'Sıcaklık düzeltme katsayısı',
    );

    _validateCorrectionFactor(
      value: loadFactor,
      parameterName: 'loadFactor',
      description: 'Yük düzeltme katsayısı',
    );
  }

  void _validateCorrectionFactor({
    required double value,
    required String parameterName,
    required String description,
  }) {
    if (!value.isFinite || value <= 0 || value > 1) {
      throw ArgumentError.value(
        value,
        parameterName,
        '$description 0 ile 1 arasında olmalıdır.',
      );
    }
  }
}

class FlightTimeResult {
  final double nominalCapacityAh;
  final double nominalEnergyWh;
  final double effectiveEnergyWh;
  final double usableCapacityFraction;
  final double estimatedAverageCurrentA;
  final double estimatedFlightTimeMinutes;

  const FlightTimeResult({
    required this.nominalCapacityAh,
    required this.nominalEnergyWh,
    required this.effectiveEnergyWh,
    required this.usableCapacityFraction,
    required this.estimatedAverageCurrentA,
    required this.estimatedFlightTimeMinutes,
  });
}
