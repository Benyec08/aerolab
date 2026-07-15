import 'battery_score_service.dart';
import 'battery_system_service.dart';

/// Batarya sisteminin fiziksel sonuçlarını ve puanını kullanıcıya
/// anlaşılır mühendislik önerilerine dönüştürür.
///
/// Bu servis yeni fizik hesabı yapmaz.
/// BatterySystemResult ve BatteryScoreResult sonuçlarını yorumlar.
class BatteryRecommendationService {
  BatteryRecommendationResult generate({
    required BatterySystemResult batterySystemResult,
    required BatteryScoreResult batteryScoreResult,
  }) {
    final recommendations = <String>[];

    _addPowerDeliveryRecommendations(batterySystemResult, recommendations);

    _addVoltageRecommendations(batterySystemResult, recommendations);

    _addCRateRecommendations(batterySystemResult, recommendations);

    _addEfficiencyRecommendations(batterySystemResult, recommendations);

    if (recommendations.isEmpty) {
      recommendations.add(_safeSystemRecommendation(batteryScoreResult.status));
    }

    final severity = _determineSeverity(
      batterySystemResult: batterySystemResult,
      batteryScoreResult: batteryScoreResult,
    );

    return BatteryRecommendationResult(
      title: _titleForSeverity(severity),
      message: recommendations.join('\n'),
      severity: severity,
    );
  }

  void _addPowerDeliveryRecommendations(
    BatterySystemResult result,
    List<String> recommendations,
  ) {
    if (!result.canDeliverAveragePower) {
      recommendations.add(
        'Batarya ortalama görev gücünü karşılayamıyor. '
        'Daha yüksek voltajlı, daha düşük iç dirençli veya daha yüksek '
        'kapasiteli bir batarya sistemi kullanılmalıdır.',
      );
      return;
    }

    if (!result.canDeliverPeakPower) {
      recommendations.add(
        'Batarya peak güç talebini karşılayamıyor. '
        'Daha yüksek C-rate değerine sahip veya paralel hücre grubu '
        'bulunan bir batarya tercih edilmelidir.',
      );
    }
  }

  void _addVoltageRecommendations(
    BatterySystemResult result,
    List<String> recommendations,
  ) {
    if (!result.averageVoltageSafe) {
      recommendations.add(
        'Ortalama yük altında paket voltajı minimum güvenli sınırın '
        'altına düşüyor. Hücre sayısı artırılmalı veya paket iç direnci '
        'azaltılmalıdır.',
      );
      return;
    }

    if (!result.peakVoltageSafe) {
      recommendations.add(
        'Peak yük altında voltaj çökmesi güvenli sınırı aşıyor. '
        'Daha düşük iç dirençli batarya veya daha yüksek hücre sayısı '
        'önerilir.',
      );
    }
  }

  void _addCRateRecommendations(
    BatterySystemResult result,
    List<String> recommendations,
  ) {
    if (!result.averageCRateSafe) {
      recommendations.add(
        'Sürekli C-rate sınırı aşılıyor. Batarya kapasitesi artırılmalı '
        'veya daha yüksek sürekli deşarj oranına sahip bir paket '
        'kullanılmalıdır.',
      );
      return;
    }

    if (!result.peakCRateSafe) {
      recommendations.add(
        'Peak C-rate sınırı aşılıyor. Daha yüksek peak deşarj kapasitesine '
        'sahip bir batarya kullanılmalıdır.',
      );
    }
  }

  void _addEfficiencyRecommendations(
    BatterySystemResult result,
    List<String> recommendations,
  ) {
    if (result.loadEfficiencyFactor < 0.85) {
      recommendations.add(
        'Batarya iç direnç kayıpları yüksek. Daha düşük iç dirençli hücre, '
        'daha kalın bağlantı iletkenleri veya paralel hücre yapısı '
        'değerlendirilmelidir.',
      );
      return;
    }

    if (result.loadEfficiencyFactor < 0.95) {
      recommendations.add(
        'Batarya yük verimi kabul edilebilir ancak iyileştirilebilir. '
        'Paket iç direnci ve bağlantı kayıpları kontrol edilmelidir.',
      );
    }
  }

  String _safeSystemRecommendation(BatteryScoreStatus status) {
    switch (status) {
      case BatteryScoreStatus.excellent:
        return 'Batarya sistemi görev profili için çok uygundur. '
            'Voltaj, C-rate ve güç aktarım marjları yüksektir.';

      case BatteryScoreStatus.good:
        return 'Batarya sistemi görev profili için güvenli ve yeterlidir.';

      case BatteryScoreStatus.warning:
        return 'Batarya sistemi kullanılabilir ancak güvenlik marjları '
            'sınırlıdır. Peak yükler dikkatle izlenmelidir.';

      case BatteryScoreStatus.critical:
        return 'Batarya sistemi mevcut görev profili için uygun değildir.';
    }
  }

  BatteryRecommendationSeverity _determineSeverity({
    required BatterySystemResult batterySystemResult,
    required BatteryScoreResult batteryScoreResult,
  }) {
    if (!batterySystemResult.status.isSafe ||
        batteryScoreResult.status == BatteryScoreStatus.critical) {
      return BatteryRecommendationSeverity.critical;
    }

    if (batteryScoreResult.status == BatteryScoreStatus.warning ||
        batterySystemResult.status == BatterySystemStatus.highLoad) {
      return BatteryRecommendationSeverity.warning;
    }

    if (batteryScoreResult.status == BatteryScoreStatus.excellent) {
      return BatteryRecommendationSeverity.excellent;
    }

    return BatteryRecommendationSeverity.good;
  }

  String _titleForSeverity(BatteryRecommendationSeverity severity) {
    switch (severity) {
      case BatteryRecommendationSeverity.excellent:
        return 'Batarya Sistemi Çok İyi';

      case BatteryRecommendationSeverity.good:
        return 'Batarya Sistemi Uygun';

      case BatteryRecommendationSeverity.warning:
        return 'Batarya Sistemi Dikkat';

      case BatteryRecommendationSeverity.critical:
        return 'Batarya Sistemi Kritik';
    }
  }
}

enum BatteryRecommendationSeverity { excellent, good, warning, critical }

extension BatteryRecommendationSeverityX on BatteryRecommendationSeverity {
  bool get isSafe {
    return this == BatteryRecommendationSeverity.excellent ||
        this == BatteryRecommendationSeverity.good;
  }
}

class BatteryRecommendationResult {
  final String title;
  final String message;
  final BatteryRecommendationSeverity severity;

  const BatteryRecommendationResult({
    required this.title,
    required this.message,
    required this.severity,
  });
}
