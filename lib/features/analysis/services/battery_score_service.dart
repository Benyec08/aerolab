import 'battery_system_service.dart';

/// BatterySystemResult içindeki elektriksel ve güvenlik sonuçlarını
/// 0–100 aralığında bir batarya puanına dönüştürür.
///
/// Bu servis yeni fizik hesabı yapmaz. BatterySystemService tarafından
/// hesaplanan voltaj, C-rate, güç aktarımı ve verim sonuçlarını puanlar.
class BatteryScoreService {
  BatteryScoreResult calculate({
    required BatterySystemResult batterySystemResult,
  }) {
    final profile = batterySystemResult.chemistryProfile;
    final averageResult = batterySystemResult.averageElectricalResult;
    final peakResult = batterySystemResult.peakElectricalResult;

    final averageVoltageMarginRatio = _voltageMarginRatio(
      loadedVoltageV: averageResult.loadedVoltageV,
      minimumSafeVoltageV: batterySystemResult.minimumSafePackVoltageV,
      nominalVoltageV: batterySystemResult.nominalPackVoltageV,
    );

    final peakVoltageMarginRatio = _voltageMarginRatio(
      loadedVoltageV: peakResult.loadedVoltageV,
      minimumSafeVoltageV: batterySystemResult.minimumSafePackVoltageV,
      nominalVoltageV: batterySystemResult.nominalPackVoltageV,
    );

    final continuousCRateUsageRatio =
        averageResult.cRate / profile.recommendedContinuousCRate;

    final peakCRateUsageRatio = peakResult.cRate / profile.recommendedPeakCRate;

    final voltageScore = _calculateVoltageScore(
      averageVoltageMarginRatio: averageVoltageMarginRatio,
      peakVoltageMarginRatio: peakVoltageMarginRatio,
      averageVoltageSafe: batterySystemResult.averageVoltageSafe,
      peakVoltageSafe: batterySystemResult.peakVoltageSafe,
    );

    final cRateScore = _calculateCRateScore(
      continuousUsageRatio: continuousCRateUsageRatio,
      peakUsageRatio: peakCRateUsageRatio,
      continuousCRateSafe: batterySystemResult.averageCRateSafe,
      peakCRateSafe: batterySystemResult.peakCRateSafe,
    );

    final powerDeliveryScore = _calculatePowerDeliveryScore(
      canDeliverAveragePower: batterySystemResult.canDeliverAveragePower,
      canDeliverPeakPower: batterySystemResult.canDeliverPeakPower,
    );

    final loadEfficiencyScore = _calculateLoadEfficiencyScore(
      batterySystemResult.loadEfficiencyFactor,
    );

    final weightedScore =
        voltageScore * 0.35 +
        cRateScore * 0.30 +
        powerDeliveryScore * 0.20 +
        loadEfficiencyScore * 0.15;

    final score = weightedScore.round().clamp(0, 100);

    final status = _determineStatus(
      score: score,
      batterySystemStatus: batterySystemResult.status,
    );

    final safetyMessage = _buildSafetyMessage(
      batterySystemResult: batterySystemResult,
      status: status,
    );

    return BatteryScoreResult(
      score: score,
      voltageScore: voltageScore,
      cRateScore: cRateScore,
      powerDeliveryScore: powerDeliveryScore,
      loadEfficiencyScore: loadEfficiencyScore,
      continuousCRateUsageRatio: continuousCRateUsageRatio,
      peakCRateUsageRatio: peakCRateUsageRatio,
      averageVoltageMarginRatio: averageVoltageMarginRatio,
      peakVoltageMarginRatio: peakVoltageMarginRatio,
      status: status,
      safetyMessage: safetyMessage,
    );
  }

  double _voltageMarginRatio({
    required double loadedVoltageV,
    required double minimumSafeVoltageV,
    required double nominalVoltageV,
  }) {
    final usableVoltageRange = nominalVoltageV - minimumSafeVoltageV;

    if (usableVoltageRange <= 0) {
      return loadedVoltageV >= minimumSafeVoltageV ? 1.0 : 0.0;
    }

    return ((loadedVoltageV - minimumSafeVoltageV) / usableVoltageRange).clamp(
      0.0,
      1.0,
    );
  }

  int _calculateVoltageScore({
    required double averageVoltageMarginRatio,
    required double peakVoltageMarginRatio,
    required bool averageVoltageSafe,
    required bool peakVoltageSafe,
  }) {
    if (!peakVoltageSafe) {
      return 20;
    }

    if (!averageVoltageSafe) {
      return 10;
    }

    final weightedMargin =
        averageVoltageMarginRatio * 0.40 + peakVoltageMarginRatio * 0.60;

    return (60 + weightedMargin * 40).round().clamp(0, 100);
  }

  int _calculateCRateScore({
    required double continuousUsageRatio,
    required double peakUsageRatio,
    required bool continuousCRateSafe,
    required bool peakCRateSafe,
  }) {
    if (!peakCRateSafe) {
      return 20;
    }

    if (!continuousCRateSafe) {
      return 10;
    }

    final worstUsageRatio = continuousUsageRatio > peakUsageRatio
        ? continuousUsageRatio
        : peakUsageRatio;

    if (worstUsageRatio <= 0.50) {
      return 100;
    }

    if (worstUsageRatio <= 0.75) {
      return 90;
    }

    if (worstUsageRatio <= 0.90) {
      return 75;
    }

    return 60;
  }

  int _calculatePowerDeliveryScore({
    required bool canDeliverAveragePower,
    required bool canDeliverPeakPower,
  }) {
    if (!canDeliverAveragePower) {
      return 0;
    }

    if (!canDeliverPeakPower) {
      return 25;
    }

    return 100;
  }

  int _calculateLoadEfficiencyScore(double efficiency) {
    if (efficiency >= 0.98) {
      return 100;
    }

    if (efficiency >= 0.95) {
      return 90;
    }

    if (efficiency >= 0.90) {
      return 75;
    }

    if (efficiency >= 0.85) {
      return 60;
    }

    return 35;
  }

  BatteryScoreStatus _determineStatus({
    required int score,
    required BatterySystemStatus batterySystemStatus,
  }) {
    if (!batterySystemStatus.isSafe) {
      return BatteryScoreStatus.critical;
    }

    if (score >= 90) {
      return BatteryScoreStatus.excellent;
    }

    if (score >= 75) {
      return BatteryScoreStatus.good;
    }

    if (score >= 60) {
      return BatteryScoreStatus.warning;
    }

    return BatteryScoreStatus.critical;
  }

  String _buildSafetyMessage({
    required BatterySystemResult batterySystemResult,
    required BatteryScoreStatus status,
  }) {
    switch (batterySystemResult.status) {
      case BatterySystemStatus.peakPowerUnavailable:
        return 'Batarya peak görev gücü talebini karşılayamıyor.';

      case BatterySystemStatus.averagePowerUnavailable:
        return 'Batarya ortalama görev gücü talebini karşılayamıyor.';

      case BatterySystemStatus.peakVoltageUnsafe:
        return 'Peak yük altında paket voltajı minimum güvenli sınırın altına düşüyor.';

      case BatterySystemStatus.averageVoltageUnsafe:
        return 'Ortalama yük altında paket voltajı minimum güvenli sınırın altına düşüyor.';

      case BatterySystemStatus.peakCRateExceeded:
        return 'Peak C-rate, batarya kimyası için önerilen sınırı aşıyor.';

      case BatterySystemStatus.continuousCRateExceeded:
        return 'Sürekli C-rate, batarya kimyası için önerilen sınırı aşıyor.';

      case BatterySystemStatus.highLoad:
        return 'Batarya güvenli çalışıyor ancak yük seviyesi yüksek.';

      case BatterySystemStatus.good:
        break;
    }

    switch (status) {
      case BatteryScoreStatus.excellent:
        return 'Batarya voltajı, C-rate ve güç aktarımı açısından çok iyi durumda.';

      case BatteryScoreStatus.good:
        return 'Batarya sistemi görev profili için güvenli ve yeterli.';

      case BatteryScoreStatus.warning:
        return 'Batarya sistemi çalışabilir ancak güvenlik marjları sınırlı.';

      case BatteryScoreStatus.critical:
        return 'Batarya sistemi mevcut görev profili için kritik durumda.';
    }
  }
}

enum BatteryScoreStatus { excellent, good, warning, critical }

extension BatteryScoreStatusX on BatteryScoreStatus {
  String get label {
    switch (this) {
      case BatteryScoreStatus.excellent:
        return 'Batarya Sistemi Çok İyi';

      case BatteryScoreStatus.good:
        return 'Batarya Sistemi İyi';

      case BatteryScoreStatus.warning:
        return 'Batarya Sistemi Dikkat';

      case BatteryScoreStatus.critical:
        return 'Batarya Sistemi Kritik';
    }
  }

  bool get isSafe {
    return this == BatteryScoreStatus.excellent ||
        this == BatteryScoreStatus.good;
  }
}

class BatteryScoreResult {
  final int score;

  final int voltageScore;
  final int cRateScore;
  final int powerDeliveryScore;
  final int loadEfficiencyScore;

  final double continuousCRateUsageRatio;
  final double peakCRateUsageRatio;

  final double averageVoltageMarginRatio;
  final double peakVoltageMarginRatio;

  final BatteryScoreStatus status;
  final String safetyMessage;

  const BatteryScoreResult({
    required this.score,
    required this.voltageScore,
    required this.cRateScore,
    required this.powerDeliveryScore,
    required this.loadEfficiencyScore,
    required this.continuousCRateUsageRatio,
    required this.peakCRateUsageRatio,
    required this.averageVoltageMarginRatio,
    required this.peakVoltageMarginRatio,
    required this.status,
    required this.safetyMessage,
  });
}
