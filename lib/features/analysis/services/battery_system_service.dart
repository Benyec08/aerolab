import 'battery_chemistry_service.dart';
import 'battery_discharge_curve_service.dart';
import 'battery_electrical_service.dart';

/// Batarya kimyası, hücre yapısı, iç direnç, görev gücü ve deşarj
/// eğrisini tek bir mühendislik analizinde birleştirir.
class BatterySystemService {
  static const double defaultReserveFraction = 0.15;
  static const double defaultBatteryHealth = 1.0;
  static const double defaultTemperatureFactor = 1.0;

  final BatteryChemistryService _chemistryService;
  final BatteryElectricalService _electricalService;
  final BatteryDischargeCurveService _dischargeCurveService;

  BatterySystemService({
    BatteryChemistryService? chemistryService,
    BatteryElectricalService? electricalService,
    BatteryDischargeCurveService? dischargeCurveService,
  }) : _chemistryService = chemistryService ?? BatteryChemistryService(),
       _electricalService = electricalService ?? BatteryElectricalService(),
       _dischargeCurveService =
           dischargeCurveService ?? BatteryDischargeCurveService();

  BatterySystemResult calculate({
    required String batteryType,
    required int cellCount,
    required double capacityMah,
    required double cellInternalResistanceMilliOhm,
    required double averageMissionPowerW,
    required double peakMissionPowerW,
    double reserveFraction = defaultReserveFraction,
    double batteryHealth = defaultBatteryHealth,
    double temperatureFactor = defaultTemperatureFactor,
  }) {
    _validateInputs(
      cellCount: cellCount,
      capacityMah: capacityMah,
      cellInternalResistanceMilliOhm: cellInternalResistanceMilliOhm,
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
      reserveFraction: reserveFraction,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
    );

    final profile = _chemistryService.getProfile(batteryType);
    final capacityAh = capacityMah / 1000.0;

    final fullPackVoltageV = profile.fullPackVoltageV(cellCount);
    final nominalPackVoltageV = profile.nominalPackVoltageV(cellCount);
    final minimumSafePackVoltageV = profile.minimumSafePackVoltageV(cellCount);

    final effectiveCellResistanceMilliOhm = cellInternalResistanceMilliOhm > 0
        ? cellInternalResistanceMilliOhm
        : profile.defaultCellInternalResistanceMilliOhm;

    final packInternalResistanceOhm =
        effectiveCellResistanceMilliOhm * cellCount / 1000.0;

    final averageElectricalResult = _electricalService.calculate(
      requestedPowerW: averageMissionPowerW,
      openCircuitVoltageV: nominalPackVoltageV,
      packInternalResistanceOhm: packInternalResistanceOhm,
      capacityAh: capacityAh,
    );

    final peakElectricalResult = _electricalService.calculate(
      requestedPowerW: peakMissionPowerW,
      openCircuitVoltageV: nominalPackVoltageV,
      packInternalResistanceOhm: packInternalResistanceOhm,
      capacityAh: capacityAh,
    );

    final averageVoltageSafe =
        averageElectricalResult.loadedVoltageV >= minimumSafePackVoltageV;

    final peakVoltageSafe =
        peakElectricalResult.loadedVoltageV >= minimumSafePackVoltageV;

    final averageCRateSafe =
        averageElectricalResult.cRate <= profile.recommendedContinuousCRate;

    final peakCRateSafe =
        peakElectricalResult.cRate <= profile.recommendedPeakCRate;

    final canDeliverAveragePower =
        averageElectricalResult.canDeliverRequestedPower;

    final canDeliverPeakPower = peakElectricalResult.canDeliverRequestedPower;

    // Terminale verilen faydalı güç / batarya kimyasından çekilen toplam güç.
    //
    // Bu katsayı iç direnç kaybını kullanılabilir enerji hesabına bir kez
    // uygular. Uçuş süresi daha sonra terminal görev gücüne bölündüğü için
    // aynı kayıp ikinci kez sayılmaz.
    final averageBatteryInputPowerW =
        averageMissionPowerW +
        averageElectricalResult.internalResistancePowerLossW;

    final loadEfficiencyFactor = averageBatteryInputPowerW > 0
        ? averageMissionPowerW / averageBatteryInputPowerW
        : 1.0;

    final dischargeCurveResult = _dischargeCurveService.calculate(
      chemistryProfile: profile,
      cellCount: cellCount,
      capacityAh: capacityAh,
      reserveFraction: reserveFraction,
      batteryHealth: batteryHealth,
      temperatureFactor: temperatureFactor,
      loadEfficiencyFactor: loadEfficiencyFactor.clamp(0.0001, 1.0),
    );

    final realUsableEnergyWh = dischargeCurveResult.correctedUsableEnergyWh;

    final estimatedFlightTimeMinutes = averageMissionPowerW > 0
        ? realUsableEnergyWh / averageMissionPowerW * 60.0
        : 0.0;

    final status = _determineStatus(
      canDeliverAveragePower: canDeliverAveragePower,
      canDeliverPeakPower: canDeliverPeakPower,
      averageVoltageSafe: averageVoltageSafe,
      peakVoltageSafe: peakVoltageSafe,
      averageCRateSafe: averageCRateSafe,
      peakCRateSafe: peakCRateSafe,
      averageCRate: averageElectricalResult.cRate,
      peakCRate: peakElectricalResult.cRate,
      recommendedContinuousCRate: profile.recommendedContinuousCRate,
      recommendedPeakCRate: profile.recommendedPeakCRate,
    );

    return BatterySystemResult(
      chemistryProfile: profile,
      capacityAh: capacityAh,
      fullPackVoltageV: fullPackVoltageV,
      nominalPackVoltageV: nominalPackVoltageV,
      minimumSafePackVoltageV: minimumSafePackVoltageV,
      cellInternalResistanceMilliOhm: effectiveCellResistanceMilliOhm,
      packInternalResistanceOhm: packInternalResistanceOhm,
      averageElectricalResult: averageElectricalResult,
      peakElectricalResult: peakElectricalResult,
      dischargeCurveResult: dischargeCurveResult,
      nominalEnergyWh: dischargeCurveResult.nominalEnergyWh,
      realUsableEnergyWh: realUsableEnergyWh,
      loadEfficiencyFactor: loadEfficiencyFactor,
      estimatedFlightTimeMinutes: estimatedFlightTimeMinutes,
      averageVoltageSafe: averageVoltageSafe,
      peakVoltageSafe: peakVoltageSafe,
      averageCRateSafe: averageCRateSafe,
      peakCRateSafe: peakCRateSafe,
      canDeliverAveragePower: canDeliverAveragePower,
      canDeliverPeakPower: canDeliverPeakPower,
      status: status,
    );
  }

  BatterySystemStatus _determineStatus({
    required bool canDeliverAveragePower,
    required bool canDeliverPeakPower,
    required bool averageVoltageSafe,
    required bool peakVoltageSafe,
    required bool averageCRateSafe,
    required bool peakCRateSafe,
    required double averageCRate,
    required double peakCRate,
    required double recommendedContinuousCRate,
    required double recommendedPeakCRate,
  }) {
    if (!canDeliverPeakPower) {
      return BatterySystemStatus.peakPowerUnavailable;
    }

    if (!canDeliverAveragePower) {
      return BatterySystemStatus.averagePowerUnavailable;
    }

    if (!peakVoltageSafe) {
      return BatterySystemStatus.peakVoltageUnsafe;
    }

    if (!averageVoltageSafe) {
      return BatterySystemStatus.averageVoltageUnsafe;
    }

    if (!peakCRateSafe) {
      return BatterySystemStatus.peakCRateExceeded;
    }

    if (!averageCRateSafe) {
      return BatterySystemStatus.continuousCRateExceeded;
    }

    final continuousUsageRatio = averageCRate / recommendedContinuousCRate;

    final peakUsageRatio = peakCRate / recommendedPeakCRate;

    if (continuousUsageRatio >= 0.85 || peakUsageRatio >= 0.90) {
      return BatterySystemStatus.highLoad;
    }

    return BatterySystemStatus.good;
  }

  void _validateInputs({
    required int cellCount,
    required double capacityMah,
    required double cellInternalResistanceMilliOhm,
    required double averageMissionPowerW,
    required double peakMissionPowerW,
    required double reserveFraction,
    required double batteryHealth,
    required double temperatureFactor,
  }) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    if (!capacityMah.isFinite || capacityMah <= 0) {
      throw ArgumentError.value(
        capacityMah,
        'capacityMah',
        'Batarya kapasitesi sıfırdan büyük olmalıdır.',
      );
    }

    if (!cellInternalResistanceMilliOhm.isFinite ||
        cellInternalResistanceMilliOhm < 0) {
      throw ArgumentError.value(
        cellInternalResistanceMilliOhm,
        'cellInternalResistanceMilliOhm',
        'Hücre iç direnci sıfır veya pozitif olmalıdır.',
      );
    }

    if (!averageMissionPowerW.isFinite || averageMissionPowerW <= 0) {
      throw ArgumentError.value(
        averageMissionPowerW,
        'averageMissionPowerW',
        'Ortalama görev gücü sıfırdan büyük olmalıdır.',
      );
    }

    if (!peakMissionPowerW.isFinite || peakMissionPowerW <= 0) {
      throw ArgumentError.value(
        peakMissionPowerW,
        'peakMissionPowerW',
        'Peak görev gücü sıfırdan büyük olmalıdır.',
      );
    }

    if (peakMissionPowerW < averageMissionPowerW) {
      throw ArgumentError(
        'Peak görev gücü, ortalama görev gücünden küçük olamaz.',
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

enum BatterySystemStatus {
  good,
  highLoad,
  continuousCRateExceeded,
  peakCRateExceeded,
  averageVoltageUnsafe,
  peakVoltageUnsafe,
  averagePowerUnavailable,
  peakPowerUnavailable,
}

extension BatterySystemStatusX on BatterySystemStatus {
  String get label {
    switch (this) {
      case BatterySystemStatus.good:
        return 'Batarya Sistemi İyi';
      case BatterySystemStatus.highLoad:
        return 'Batarya Yükü Yüksek';
      case BatterySystemStatus.continuousCRateExceeded:
        return 'Sürekli C-rate Limiti Aşıldı';
      case BatterySystemStatus.peakCRateExceeded:
        return 'Peak C-rate Limiti Aşıldı';
      case BatterySystemStatus.averageVoltageUnsafe:
        return 'Ortalama Yük Voltajı Güvensiz';
      case BatterySystemStatus.peakVoltageUnsafe:
        return 'Peak Yük Voltajı Güvensiz';
      case BatterySystemStatus.averagePowerUnavailable:
        return 'Ortalama Güç Talebi Karşılanamıyor';
      case BatterySystemStatus.peakPowerUnavailable:
        return 'Peak Güç Talebi Karşılanamıyor';
    }
  }

  bool get isSafe {
    return this == BatterySystemStatus.good ||
        this == BatterySystemStatus.highLoad;
  }
}

class BatterySystemResult {
  final BatteryChemistryProfile chemistryProfile;
  final double capacityAh;

  final double fullPackVoltageV;
  final double nominalPackVoltageV;
  final double minimumSafePackVoltageV;

  final double cellInternalResistanceMilliOhm;
  final double packInternalResistanceOhm;

  final BatteryElectricalResult averageElectricalResult;
  final BatteryElectricalResult peakElectricalResult;
  final BatteryDischargeCurveResult dischargeCurveResult;

  final double nominalEnergyWh;
  final double realUsableEnergyWh;

  /// İç direnç kayıpları sonrası terminale aktarılabilen güç oranı.
  final double loadEfficiencyFactor;

  final double estimatedFlightTimeMinutes;

  final bool averageVoltageSafe;
  final bool peakVoltageSafe;
  final bool averageCRateSafe;
  final bool peakCRateSafe;
  final bool canDeliverAveragePower;
  final bool canDeliverPeakPower;

  final BatterySystemStatus status;

  const BatterySystemResult({
    required this.chemistryProfile,
    required this.capacityAh,
    required this.fullPackVoltageV,
    required this.nominalPackVoltageV,
    required this.minimumSafePackVoltageV,
    required this.cellInternalResistanceMilliOhm,
    required this.packInternalResistanceOhm,
    required this.averageElectricalResult,
    required this.peakElectricalResult,
    required this.dischargeCurveResult,
    required this.nominalEnergyWh,
    required this.realUsableEnergyWh,
    required this.loadEfficiencyFactor,
    required this.estimatedFlightTimeMinutes,
    required this.averageVoltageSafe,
    required this.peakVoltageSafe,
    required this.averageCRateSafe,
    required this.peakCRateSafe,
    required this.canDeliverAveragePower,
    required this.canDeliverPeakPower,
    required this.status,
  });
}
