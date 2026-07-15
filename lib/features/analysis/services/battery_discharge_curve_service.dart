import 'battery_chemistry_service.dart';

/// Bataryanın deşarj boyunca değişen açık devre voltajını ve
/// kullanılabilir enerjisini kimyaya bağlı bir eğriyle hesaplar.
///
/// Model, batarya davranışını belirli şarj seviyelerinde tanımlanan
/// voltaj noktaları arasında doğrusal enterpolasyonla temsil eder.
///
/// Bu model zaman bağımlı termal simülasyon yapmaz. Ancak nominal
/// voltaj × kapasite yaklaşımına göre deşarj eğrisini daha gerçekçi
/// biçimde hesaba katar.
class BatteryDischargeCurveService {
  static const int defaultIntegrationSteps = 200;

  BatteryDischargeCurveResult calculate({
    required BatteryChemistryProfile chemistryProfile,
    required int cellCount,
    required double capacityAh,
    required double reserveFraction,
    double batteryHealth = 1.0,
    double temperatureFactor = 1.0,
    double loadEfficiencyFactor = 1.0,
    int integrationSteps = defaultIntegrationSteps,
  }) {
    _validateInputs(
      cellCount: cellCount,
      capacityAh: capacityAh,
      reserveFraction: reserveFraction,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
      loadEfficiencyFactor: loadEfficiencyFactor,
      integrationSteps: integrationSteps,
    );

    final curve = _curveForChemistry(chemistryProfile.chemistryName);

    final usableStateOfChargeFraction = 1.0 - reserveFraction;

    final nominalEnergyWh =
        chemistryProfile.nominalPackVoltageV(cellCount) * capacityAh;

    final curveEnergyWh = _integrateCurveEnergy(
      curve: curve,
      chemistryProfile: chemistryProfile,
      cellCount: cellCount,
      capacityAh: capacityAh,
      minimumStateOfChargeFraction: reserveFraction,
      integrationSteps: integrationSteps,
    );

    final correctedUsableEnergyWh =
        curveEnergyWh *
        batteryHealth *
        temperatureFactor *
        loadEfficiencyFactor;

    final usableEnergyFraction = nominalEnergyWh > 0
        ? correctedUsableEnergyWh / nominalEnergyWh
        : 0.0;

    final averageUsablePackVoltageV =
        capacityAh * usableStateOfChargeFraction > 0
        ? curveEnergyWh / (capacityAh * usableStateOfChargeFraction)
        : 0.0;

    return BatteryDischargeCurveResult(
      nominalEnergyWh: nominalEnergyWh,
      curveIntegratedEnergyWh: curveEnergyWh,
      correctedUsableEnergyWh: correctedUsableEnergyWh,
      usableStateOfChargeFraction: usableStateOfChargeFraction,
      usableEnergyFraction: usableEnergyFraction,
      averageUsablePackVoltageV: averageUsablePackVoltageV,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
      loadEfficiencyFactor: loadEfficiencyFactor,
    );
  }

  /// Verilen şarj seviyesi için tek hücre açık devre voltajını döndürür.
  ///
  /// stateOfChargeFraction:
  /// 1.0 → %100 dolu
  /// 0.0 → tamamen boş
  double cellVoltageAtStateOfCharge({
    required String chemistryName,
    required double stateOfChargeFraction,
  }) {
    if (!stateOfChargeFraction.isFinite ||
        stateOfChargeFraction < 0 ||
        stateOfChargeFraction > 1) {
      throw ArgumentError.value(
        stateOfChargeFraction,
        'stateOfChargeFraction',
        'Şarj seviyesi 0 ile 1 arasında olmalıdır.',
      );
    }

    final curve = _curveForChemistry(chemistryName);

    return _interpolateVoltage(curve, stateOfChargeFraction);
  }

  double _integrateCurveEnergy({
    required List<BatteryDischargePoint> curve,
    required BatteryChemistryProfile chemistryProfile,
    required int cellCount,
    required double capacityAh,
    required double minimumStateOfChargeFraction,
    required int integrationSteps,
  }) {
    final usableSocRange = 1.0 - minimumStateOfChargeFraction;
    final stepSoc = usableSocRange / integrationSteps;

    var accumulatedEnergyWh = 0.0;

    for (var index = 0; index < integrationSteps; index++) {
      final upperSoc = 1.0 - index * stepSoc;
      final lowerSoc = upperSoc - stepSoc;
      final midpointSoc = (upperSoc + lowerSoc) / 2.0;

      var cellVoltage = _interpolateVoltage(curve, midpointSoc);

      if (cellVoltage < chemistryProfile.minimumSafeCellVoltageV) {
        cellVoltage = chemistryProfile.minimumSafeCellVoltageV;
      }

      final packVoltage = cellVoltage * cellCount;
      final dischargedCapacityAh = capacityAh * stepSoc;

      accumulatedEnergyWh += packVoltage * dischargedCapacityAh;
    }

    return accumulatedEnergyWh;
  }

  double _interpolateVoltage(
    List<BatteryDischargePoint> curve,
    double stateOfChargeFraction,
  ) {
    if (stateOfChargeFraction >= curve.first.stateOfChargeFraction) {
      return curve.first.cellVoltageV;
    }

    if (stateOfChargeFraction <= curve.last.stateOfChargeFraction) {
      return curve.last.cellVoltageV;
    }

    for (var index = 0; index < curve.length - 1; index++) {
      final upperPoint = curve[index];
      final lowerPoint = curve[index + 1];

      final isInsideSegment =
          stateOfChargeFraction <= upperPoint.stateOfChargeFraction &&
          stateOfChargeFraction >= lowerPoint.stateOfChargeFraction;

      if (!isInsideSegment) {
        continue;
      }

      final segmentSize =
          upperPoint.stateOfChargeFraction - lowerPoint.stateOfChargeFraction;

      final position =
          (stateOfChargeFraction - lowerPoint.stateOfChargeFraction) /
          segmentSize;

      return lowerPoint.cellVoltageV +
          position * (upperPoint.cellVoltageV - lowerPoint.cellVoltageV);
    }

    return curve.last.cellVoltageV;
  }

  List<BatteryDischargePoint> _curveForChemistry(String chemistryName) {
    final normalizedName = chemistryName
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    switch (normalizedName) {
      case 'lipo':
        return const [
          BatteryDischargePoint(1.00, 4.20),
          BatteryDischargePoint(0.90, 4.05),
          BatteryDischargePoint(0.75, 3.90),
          BatteryDischargePoint(0.50, 3.78),
          BatteryDischargePoint(0.25, 3.70),
          BatteryDischargePoint(0.15, 3.60),
          BatteryDischargePoint(0.05, 3.40),
          BatteryDischargePoint(0.00, 3.30),
        ];

      case 'liion':
      case 'lion':
        return const [
          BatteryDischargePoint(1.00, 4.20),
          BatteryDischargePoint(0.90, 4.05),
          BatteryDischargePoint(0.75, 3.85),
          BatteryDischargePoint(0.50, 3.65),
          BatteryDischargePoint(0.25, 3.45),
          BatteryDischargePoint(0.15, 3.30),
          BatteryDischargePoint(0.05, 3.10),
          BatteryDischargePoint(0.00, 3.00),
        ];

      case 'lihv':
        return const [
          BatteryDischargePoint(1.00, 4.35),
          BatteryDischargePoint(0.90, 4.18),
          BatteryDischargePoint(0.75, 4.00),
          BatteryDischargePoint(0.50, 3.85),
          BatteryDischargePoint(0.25, 3.75),
          BatteryDischargePoint(0.15, 3.65),
          BatteryDischargePoint(0.05, 3.42),
          BatteryDischargePoint(0.00, 3.30),
        ];

      default:
        throw ArgumentError.value(
          chemistryName,
          'chemistryName',
          'Desteklenmeyen batarya kimyası.',
        );
    }
  }

  void _validateInputs({
    required int cellCount,
    required double capacityAh,
    required double reserveFraction,
    required double batteryHealth,
    required double temperatureFactor,
    required double loadEfficiencyFactor,
    required int integrationSteps,
  }) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    if (!capacityAh.isFinite || capacityAh <= 0) {
      throw ArgumentError.value(
        capacityAh,
        'capacityAh',
        'Batarya kapasitesi sıfırdan büyük olmalıdır.',
      );
    }

    if (!reserveFraction.isFinite ||
        reserveFraction < 0 ||
        reserveFraction >= 1) {
      throw ArgumentError.value(
        reserveFraction,
        'reserveFraction',
        'Rezerv oranı 0 dahil, 1 hariç olmalıdır.',
      );
    }

    _validateFactor(batteryHealth, 'batteryHealth');
    _validateFactor(temperatureFactor, 'temperatureFactor');
    _validateFactor(loadEfficiencyFactor, 'loadEfficiencyFactor');

    if (integrationSteps < 10) {
      throw ArgumentError.value(
        integrationSteps,
        'integrationSteps',
        'Entegrasyon adımı en az 10 olmalıdır.',
      );
    }
  }

  void _validateFactor(double value, String parameterName) {
    if (!value.isFinite || value <= 0 || value > 1) {
      throw ArgumentError.value(
        value,
        parameterName,
        'Düzeltme katsayısı 0 ile 1 arasında olmalıdır.',
      );
    }
  }
}

class BatteryDischargePoint {
  final double stateOfChargeFraction;
  final double cellVoltageV;

  const BatteryDischargePoint(this.stateOfChargeFraction, this.cellVoltageV);
}

class BatteryDischargeCurveResult {
  /// Nominal hücre voltajı üzerinden hesaplanan teorik enerji.
  final double nominalEnergyWh;

  /// Deşarj voltaj eğrisinin sayısal integrasyonuyla hesaplanan enerji.
  final double curveIntegratedEnergyWh;

  /// Sağlık, sıcaklık ve yük kayıpları uygulandıktan sonraki gerçek enerji.
  final double correctedUsableEnergyWh;

  final double usableStateOfChargeFraction;
  final double usableEnergyFraction;

  /// Kullanılabilir deşarj aralığındaki ortalama paket voltajı.
  final double averageUsablePackVoltageV;

  final double batteryHealth;
  final double temperatureFactor;
  final double loadEfficiencyFactor;

  const BatteryDischargeCurveResult({
    required this.nominalEnergyWh,
    required this.curveIntegratedEnergyWh,
    required this.correctedUsableEnergyWh,
    required this.usableStateOfChargeFraction,
    required this.usableEnergyFraction,
    required this.averageUsablePackVoltageV,
    required this.batteryHealth,
    required this.temperatureFactor,
    required this.loadEfficiencyFactor,
  });
}
