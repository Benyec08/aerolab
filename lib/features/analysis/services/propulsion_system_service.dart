import 'propulsion_load_service.dart';
import 'propulsion_power_chain_service.dart';

/// Propulsion güç zincirini ve motor yük durumunu tek analizde birleştirir.
///
/// Bu servis:
///
/// - Ortalama görev gücü için güç zincirini,
/// - Peak görev gücü için güç zincirini,
/// - Sürekli ve maksimum motor yüklerini,
/// - Toplam propulsion sistem durumunu
///
/// hesaplar.
class PropulsionSystemService {
  final PropulsionPowerChainService _powerChainService;
  final PropulsionLoadService _loadService;

  PropulsionSystemService({
    PropulsionPowerChainService? powerChainService,
    PropulsionLoadService? loadService,
  }) : _powerChainService = powerChainService ?? PropulsionPowerChainService(),
       _loadService = loadService ?? PropulsionLoadService();

  PropulsionSystemResult calculate({
    required double averageMissionPowerW,
    required double peakMissionPowerW,
    required double escEfficiency,
    required double motorEfficiency,
    required double propellerEfficiency,
    required double continuousMotorPowerW,
    required double maximumMotorPowerW,
  }) {
    final averagePowerChain = _powerChainService.calculate(
      batteryElectricalPowerW: averageMissionPowerW,
      escEfficiency: escEfficiency,
      motorEfficiency: motorEfficiency,
      propellerEfficiency: propellerEfficiency,
    );

    final peakPowerChain = _powerChainService.calculate(
      batteryElectricalPowerW: peakMissionPowerW,
      escEfficiency: escEfficiency,
      motorEfficiency: motorEfficiency,
      propellerEfficiency: propellerEfficiency,
    );

    final loadAnalysis = _loadService.calculate(
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
      continuousMotorPowerW: continuousMotorPowerW,
      maximumMotorPowerW: maximumMotorPowerW,
    );

    final totalEfficiency = averagePowerChain.totalPropulsionEfficiency;

    final averageUsefulPowerReserveW =
        continuousMotorPowerW - averagePowerChain.usefulPropulsivePowerW;

    final peakUsefulPowerReserveW =
        maximumMotorPowerW - peakPowerChain.usefulPropulsivePowerW;

    final status = _determineSystemStatus(
      loadAnalysis: loadAnalysis,
      totalEfficiency: totalEfficiency,
    );

    return PropulsionSystemResult(
      averagePowerChain: averagePowerChain,
      peakPowerChain: peakPowerChain,
      loadAnalysis: loadAnalysis,
      totalPropulsionEfficiency: totalEfficiency,
      averageUsefulPowerReserveW: averageUsefulPowerReserveW,
      peakUsefulPowerReserveW: peakUsefulPowerReserveW,
      status: status,
    );
  }

  PropulsionSystemStatus _determineSystemStatus({
    required PropulsionLoadResult loadAnalysis,
    required double totalEfficiency,
  }) {
    if (loadAnalysis.exceedsMaximumLimit) {
      return PropulsionSystemStatus.maximumPowerExceeded;
    }

    if (loadAnalysis.exceedsContinuousLimit) {
      return PropulsionSystemStatus.continuousPowerExceeded;
    }

    if (totalEfficiency < 0.45) {
      return PropulsionSystemStatus.inefficient;
    }

    if (loadAnalysis.status == PropulsionLoadStatus.critical) {
      return PropulsionSystemStatus.criticalLoad;
    }

    if (loadAnalysis.status == PropulsionLoadStatus.high) {
      return PropulsionSystemStatus.highLoad;
    }

    if (totalEfficiency < 0.60) {
      return PropulsionSystemStatus.acceptable;
    }

    return PropulsionSystemStatus.good;
  }
}

enum PropulsionSystemStatus {
  good,
  acceptable,
  inefficient,
  highLoad,
  criticalLoad,
  continuousPowerExceeded,
  maximumPowerExceeded,
}

extension PropulsionSystemStatusX on PropulsionSystemStatus {
  String get label {
    switch (this) {
      case PropulsionSystemStatus.good:
        return 'Propulsion Sistemi İyi';

      case PropulsionSystemStatus.acceptable:
        return 'Propulsion Verimi Kabul Edilebilir';

      case PropulsionSystemStatus.inefficient:
        return 'Propulsion Verimi Düşük';

      case PropulsionSystemStatus.highLoad:
        return 'Motor Yükü Yüksek';

      case PropulsionSystemStatus.criticalLoad:
        return 'Motor Yükü Kritik';

      case PropulsionSystemStatus.continuousPowerExceeded:
        return 'Sürekli Motor Gücü Aşıldı';

      case PropulsionSystemStatus.maximumPowerExceeded:
        return 'Maksimum Motor Gücü Aşıldı';
    }
  }

  bool get isSafe {
    return this == PropulsionSystemStatus.good ||
        this == PropulsionSystemStatus.acceptable;
  }
}

class PropulsionSystemResult {
  /// Ortalama görev gücü için hesaplanan güç zinciri.
  final PropulsionPowerChainResult averagePowerChain;

  /// Peak görev gücü için hesaplanan güç zinciri.
  final PropulsionPowerChainResult peakPowerChain;

  /// Sürekli ve maksimum motor yük analizi.
  final PropulsionLoadResult loadAnalysis;

  /// ESC × motor × pervane toplam propulsion verimi.
  ///
  /// 0–1 aralığındadır.
  final double totalPropulsionEfficiency;

  /// Sürekli motor gücü ile ortalama faydalı güç arasındaki fark.
  final double averageUsefulPowerReserveW;

  /// Maksimum motor gücü ile peak faydalı güç arasındaki fark.
  final double peakUsefulPowerReserveW;

  final PropulsionSystemStatus status;

  const PropulsionSystemResult({
    required this.averagePowerChain,
    required this.peakPowerChain,
    required this.loadAnalysis,
    required this.totalPropulsionEfficiency,
    required this.averageUsefulPowerReserveW,
    required this.peakUsefulPowerReserveW,
    required this.status,
  });
}
