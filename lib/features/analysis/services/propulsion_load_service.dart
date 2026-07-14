/// Motor sisteminin ortalama ve peak görev güçleri karşısındaki
/// yük durumunu analiz eder.
///
/// Güç değerleri, toplam motor sistemi için watt cinsindedir.
class PropulsionLoadService {
  PropulsionLoadResult calculate({
    required double averageMissionPowerW,
    required double peakMissionPowerW,
    required double continuousMotorPowerW,
    required double maximumMotorPowerW,
  }) {
    _validateInputs(
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
      continuousMotorPowerW: continuousMotorPowerW,
      maximumMotorPowerW: maximumMotorPowerW,
    );

    final averageContinuousLoadRatio =
        averageMissionPowerW / continuousMotorPowerW;

    final peakContinuousLoadRatio = peakMissionPowerW / continuousMotorPowerW;

    final peakMaximumLoadRatio = peakMissionPowerW / maximumMotorPowerW;

    final continuousPowerReserveW =
        continuousMotorPowerW - averageMissionPowerW;

    final maximumPowerReserveW = maximumMotorPowerW - peakMissionPowerW;

    final exceedsContinuousLimit = averageMissionPowerW > continuousMotorPowerW;

    final peakExceedsContinuousLimit =
        peakMissionPowerW > continuousMotorPowerW;

    final exceedsMaximumLimit = peakMissionPowerW > maximumMotorPowerW;

    final status = _determineStatus(
      averageContinuousLoadRatio: averageContinuousLoadRatio,
      peakContinuousLoadRatio: peakContinuousLoadRatio,
      peakMaximumLoadRatio: peakMaximumLoadRatio,
      exceedsContinuousLimit: exceedsContinuousLimit,
      exceedsMaximumLimit: exceedsMaximumLimit,
    );

    return PropulsionLoadResult(
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
      continuousMotorPowerW: continuousMotorPowerW,
      maximumMotorPowerW: maximumMotorPowerW,
      averageContinuousLoadRatio: averageContinuousLoadRatio,
      peakContinuousLoadRatio: peakContinuousLoadRatio,
      peakMaximumLoadRatio: peakMaximumLoadRatio,
      continuousPowerReserveW: continuousPowerReserveW,
      maximumPowerReserveW: maximumPowerReserveW,
      exceedsContinuousLimit: exceedsContinuousLimit,
      peakExceedsContinuousLimit: peakExceedsContinuousLimit,
      exceedsMaximumLimit: exceedsMaximumLimit,
      status: status,
    );
  }

  PropulsionLoadStatus _determineStatus({
    required double averageContinuousLoadRatio,
    required double peakContinuousLoadRatio,
    required double peakMaximumLoadRatio,
    required bool exceedsContinuousLimit,
    required bool exceedsMaximumLimit,
  }) {
    if (exceedsMaximumLimit) {
      return PropulsionLoadStatus.maximumLimitExceeded;
    }

    if (exceedsContinuousLimit) {
      return PropulsionLoadStatus.continuousLimitExceeded;
    }

    if (peakMaximumLoadRatio >= 0.90 ||
        peakContinuousLoadRatio >= 1.0 ||
        averageContinuousLoadRatio >= 0.85) {
      return PropulsionLoadStatus.critical;
    }

    if (peakMaximumLoadRatio >= 0.75 ||
        peakContinuousLoadRatio >= 0.85 ||
        averageContinuousLoadRatio >= 0.70) {
      return PropulsionLoadStatus.high;
    }

    if (peakMaximumLoadRatio >= 0.50 ||
        peakContinuousLoadRatio >= 0.60 ||
        averageContinuousLoadRatio >= 0.45) {
      return PropulsionLoadStatus.normal;
    }

    return PropulsionLoadStatus.low;
  }

  void _validateInputs({
    required double averageMissionPowerW,
    required double peakMissionPowerW,
    required double continuousMotorPowerW,
    required double maximumMotorPowerW,
  }) {
    _validateNonNegative(averageMissionPowerW, 'averageMissionPowerW');

    _validateNonNegative(peakMissionPowerW, 'peakMissionPowerW');

    _validatePositive(continuousMotorPowerW, 'continuousMotorPowerW');

    _validatePositive(maximumMotorPowerW, 'maximumMotorPowerW');

    if (peakMissionPowerW < averageMissionPowerW) {
      throw ArgumentError(
        'Peak görev gücü, ortalama görev gücünden küçük olamaz.',
      );
    }

    if (maximumMotorPowerW < continuousMotorPowerW) {
      throw ArgumentError(
        'Maksimum motor gücü, sürekli motor gücünden küçük olamaz.',
      );
    }
  }

  void _validateNonNegative(double value, String parameterName) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        parameterName,
        'Değer sıfır veya pozitif olmalıdır.',
      );
    }
  }

  void _validatePositive(double value, String parameterName) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        parameterName,
        'Değer sıfırdan büyük olmalıdır.',
      );
    }
  }
}

enum PropulsionLoadStatus {
  low,
  normal,
  high,
  critical,
  continuousLimitExceeded,
  maximumLimitExceeded,
}

extension PropulsionLoadStatusX on PropulsionLoadStatus {
  String get label {
    switch (this) {
      case PropulsionLoadStatus.low:
        return 'Düşük Motor Yükü';
      case PropulsionLoadStatus.normal:
        return 'Normal Motor Yükü';
      case PropulsionLoadStatus.high:
        return 'Yüksek Motor Yükü';
      case PropulsionLoadStatus.critical:
        return 'Kritik Motor Yükü';
      case PropulsionLoadStatus.continuousLimitExceeded:
        return 'Sürekli Güç Limiti Aşıldı';
      case PropulsionLoadStatus.maximumLimitExceeded:
        return 'Maksimum Güç Limiti Aşıldı';
    }
  }

  bool get isSafe {
    return this == PropulsionLoadStatus.low ||
        this == PropulsionLoadStatus.normal;
  }
}

class PropulsionLoadResult {
  final double averageMissionPowerW;
  final double peakMissionPowerW;
  final double continuousMotorPowerW;
  final double maximumMotorPowerW;

  /// Ortalama görev gücünün sürekli motor gücüne oranı.
  final double averageContinuousLoadRatio;

  /// Peak görev gücünün sürekli motor gücüne oranı.
  final double peakContinuousLoadRatio;

  /// Peak görev gücünün maksimum motor gücüne oranı.
  final double peakMaximumLoadRatio;

  final double continuousPowerReserveW;
  final double maximumPowerReserveW;

  final bool exceedsContinuousLimit;
  final bool peakExceedsContinuousLimit;
  final bool exceedsMaximumLimit;

  final PropulsionLoadStatus status;

  const PropulsionLoadResult({
    required this.averageMissionPowerW,
    required this.peakMissionPowerW,
    required this.continuousMotorPowerW,
    required this.maximumMotorPowerW,
    required this.averageContinuousLoadRatio,
    required this.peakContinuousLoadRatio,
    required this.peakMaximumLoadRatio,
    required this.continuousPowerReserveW,
    required this.maximumPowerReserveW,
    required this.exceedsContinuousLimit,
    required this.peakExceedsContinuousLimit,
    required this.exceedsMaximumLimit,
    required this.status,
  });
}
