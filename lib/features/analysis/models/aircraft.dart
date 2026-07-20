import 'aircraft_mass_station.dart';

class Aircraft {
  final String name;
  final String type;
  final double weightKg;
  final double wingAreaM2;
  final double wingSpanM;
  final int motorCount;

  /// Toplam kurulu nominal motor gücü.
  ///
  /// Önceki sprintlerden gelen mevcut alan korunmaktadır.
  final double motorPowerW;

  final double propellerDiameterInch;
  final double batteryCapacityMah;
  final double batteryVoltageV;
  final String batteryType;
  final int batteryCellCount;

  // Sprint 14D
  //
  // Komponent veritabanından seçilen kayıtların kimlikleri.
  //
  // Bu alanların tamamı isteğe bağlıdır. Null olduklarında AeroLab mevcut
  // manuel giriş alanlarını kullanmaya devam eder. Böylece önceki kayıtlar,
  // analizler ve manuel çalışma akışı geriye dönük olarak korunur.
  final String? motorComponentId;
  final String? propellerComponentId;
  final String? batteryComponentId;
  final String? escComponentId;
  final String? motorPropellerCombinationId;

  // Sprint 12A
  //
  // Hücre başına iç direnç değeri mΩ cinsindedir.
  //
  // Örnek:
  // 4.0 mΩ / cell
  final double cellInternalResistanceMilliOhm;

  // Sprint 10B
  // Sabit kanat ve kanatlı VTOL araçları için aerodinamik girdiler.
  //
  // Drone araçlarında bu alanlar aerodinamik seyir analizinde kullanılmaz.
  final double cruiseSpeedMs;
  final double zeroLiftDragCoefficient;
  final double maxLiftCoefficient;
  final double oswaldEfficiencyFactor;

  // Sprint 11A
  //
  // Verim değerleri yüzde olarak değil, 0–1 aralığında saklanır.
  //
  // Örnek:
  // %95 ESC verimi   -> 0.95
  // %85 motor verimi -> 0.85
  final double escEfficiency;
  final double motorEfficiency;

  /// Motor sisteminin güvenli biçimde sürekli sağlayabildiği toplam güç.
  final double continuousMotorPowerW;

  /// Motor sisteminin kısa süreli sağlayabildiği toplam maksimum güç.
  final double maximumMotorPowerW;

  // Sprint 15E
  //
  // Boylamsal ağırlık merkezi ve statik marj analizi girdileri.
  final List<AircraftMassStation> massStations;
  final double meanAerodynamicChordM;
  final double macLeadingEdgeFromDatumM;
  final double neutralPointPercentMac;
  final double minimumCgPercentMac;
  final double maximumCgPercentMac;

  // Sprint 15F — Uçuş zarfı girdileri
  final double maximumOperatingSpeedMs;
  final double positiveLimitLoadFactor;
  final double negativeLimitLoadFactor;

  Aircraft({
    required this.name,
    required this.type,
    required this.weightKg,
    required this.wingAreaM2,
    required this.wingSpanM,
    required this.motorCount,
    required this.motorPowerW,
    required this.propellerDiameterInch,
    required this.batteryCapacityMah,
    required this.batteryVoltageV,
    required this.batteryType,
    required this.batteryCellCount,
    this.motorComponentId,
    this.propellerComponentId,
    this.batteryComponentId,
    this.escComponentId,
    this.motorPropellerCombinationId,
    double? cellInternalResistanceMilliOhm,
    this.cruiseSpeedMs = 15.0,
    this.zeroLiftDragCoefficient = 0.030,
    this.maxLiftCoefficient = 1.4,
    this.oswaldEfficiencyFactor = 0.80,
    this.escEfficiency = 0.95,
    this.motorEfficiency = 0.85,
    double? continuousMotorPowerW,
    double? maximumMotorPowerW,
    List<AircraftMassStation> massStations = const [],
    this.meanAerodynamicChordM = 0.0,
    this.macLeadingEdgeFromDatumM = 0.0,
    this.neutralPointPercentMac = 40.0,
    this.minimumCgPercentMac = 20.0,
    this.maximumCgPercentMac = 35.0,
    this.maximumOperatingSpeedMs = 25.0,
    this.positiveLimitLoadFactor = 3.8,
    this.negativeLimitLoadFactor = -1.5,
  }) : massStations = List.unmodifiable(massStations),
       cellInternalResistanceMilliOhm =
           cellInternalResistanceMilliOhm ??
           _defaultCellInternalResistanceMilliOhm(batteryType),
       continuousMotorPowerW = continuousMotorPowerW ?? motorPowerW,
       maximumMotorPowerW = maximumMotorPowerW ?? motorPowerW;

  bool get hasFlightEnvelopeInputs =>
      maximumOperatingSpeedMs.isFinite &&
      positiveLimitLoadFactor.isFinite &&
      negativeLimitLoadFactor.isFinite &&
      maximumOperatingSpeedMs > 0.0 &&
      positiveLimitLoadFactor > 1.0 &&
      negativeLimitLoadFactor < 0.0;

  bool get hasStabilityInputs =>
      massStations.isNotEmpty &&
      massStations.every((station) => station.isValid) &&
      meanAerodynamicChordM > 0.0 &&
      neutralPointPercentMac > 0.0 &&
      minimumCgPercentMac < maximumCgPercentMac;

  double get totalMassStationMassKg =>
      massStations.fold<double>(0.0, (sum, station) => sum + station.massKg);

  /// Komponent veritabanından bir motor seçilip seçilmediğini gösterir.
  bool get hasSelectedMotorComponent => _hasComponentId(motorComponentId);

  /// Komponent veritabanından bir pervane seçilip seçilmediğini gösterir.
  bool get hasSelectedPropellerComponent =>
      _hasComponentId(propellerComponentId);

  /// Komponent veritabanından bir batarya seçilip seçilmediğini gösterir.
  bool get hasSelectedBatteryComponent => _hasComponentId(batteryComponentId);

  /// Komponent veritabanından bir ESC seçilip seçilmediğini gösterir.
  bool get hasSelectedEscComponent => _hasComponentId(escComponentId);

  /// Gerçek motor-pervane test tablosu seçilip seçilmediğini gösterir.
  bool get hasSelectedMotorPropellerCombination =>
      _hasComponentId(motorPropellerCombinationId);

  /// Araçta en az bir veritabanı komponenti seçildiğini gösterir.
  bool get usesComponentDatabase =>
      hasSelectedMotorComponent ||
      hasSelectedPropellerComponent ||
      hasSelectedBatteryComponent ||
      hasSelectedEscComponent ||
      hasSelectedMotorPropellerCombination;

  /// Hiçbir komponent seçilmediyse manuel giriş akışının kullanıldığını
  /// gösterir.
  bool get usesManualComponentInputs => !usesComponentDatabase;

  static bool _hasComponentId(String? componentId) {
    return componentId != null && componentId.trim().isNotEmpty;
  }

  static double _defaultCellInternalResistanceMilliOhm(String batteryType) {
    final normalizedType = batteryType
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    switch (normalizedType) {
      case 'liion':
      case 'lion':
        return 18.0;

      case 'lihv':
        return 4.5;

      case 'lipo':
      default:
        return 4.0;
    }
  }
}
