import '../models/endurance_range_result.dart';

class EnduranceRangeService {
  const EnduranceRangeService();

  EnduranceRangeResult calculate({
    required double usableEnergyWh,
    required double cruisePowerW,
    required double cruiseSpeedMs,
    required double estimatedGroundSpeedMs,
  }) {
    if (!_inputsAreValid(
      usableEnergyWh: usableEnergyWh,
      cruisePowerW: cruisePowerW,
      cruiseSpeedMs: cruiseSpeedMs,
      estimatedGroundSpeedMs: estimatedGroundSpeedMs,
    )) {
      return const EnduranceRangeResult.notApplicable(
        message:
            'Menzil ve havada kalış hesabı için enerji, güç ve hız '
            'girdileri geçerli olmalıdır.',
      );
    }

    final enduranceHours = usableEnergyWh / cruisePowerW;
    final enduranceMinutes = enduranceHours * 60.0;

    final cruiseSpeedKmh = cruiseSpeedMs * 3.6;
    final stillAirRangeKm = enduranceHours * cruiseSpeedKmh;

    final groundSpeedKmh = estimatedGroundSpeedMs * 3.6;
    final windAdjustedRangeKm = enduranceHours * groundSpeedKmh;

    final status = _buildStatus(
      enduranceMinutes: enduranceMinutes,
      windAdjustedRangeKm: windAdjustedRangeKm,
    );

    final message = _buildMessage(
      enduranceMinutes: enduranceMinutes,
      stillAirRangeKm: stillAirRangeKm,
      windAdjustedRangeKm: windAdjustedRangeKm,
    );

    return EnduranceRangeResult(
      isApplicable: true,
      usableEnergyWh: usableEnergyWh,
      cruisePowerW: cruisePowerW,
      enduranceHours: enduranceHours,
      enduranceMinutes: enduranceMinutes,
      cruiseSpeedMs: cruiseSpeedMs,
      cruiseSpeedKmh: cruiseSpeedKmh,
      stillAirRangeKm: stillAirRangeKm,
      estimatedGroundSpeedMs: estimatedGroundSpeedMs,
      windAdjustedRangeKm: windAdjustedRangeKm,
      status: status,
      message: message,
    );
  }

  bool _inputsAreValid({
    required double usableEnergyWh,
    required double cruisePowerW,
    required double cruiseSpeedMs,
    required double estimatedGroundSpeedMs,
  }) {
    return usableEnergyWh.isFinite &&
        cruisePowerW.isFinite &&
        cruiseSpeedMs.isFinite &&
        estimatedGroundSpeedMs.isFinite &&
        usableEnergyWh > 0.0 &&
        cruisePowerW > 0.0 &&
        cruiseSpeedMs > 0.0 &&
        estimatedGroundSpeedMs >= 0.0;
  }

  String _buildStatus({
    required double enduranceMinutes,
    required double windAdjustedRangeKm,
  }) {
    if (enduranceMinutes < 10.0 || windAdjustedRangeKm < 5.0) {
      return 'Düşük';
    }

    if (enduranceMinutes < 20.0 || windAdjustedRangeKm < 15.0) {
      return 'Orta';
    }

    if (enduranceMinutes < 40.0 || windAdjustedRangeKm < 35.0) {
      return 'İyi';
    }

    return 'Yüksek';
  }

  String _buildMessage({
    required double enduranceMinutes,
    required double stillAirRangeKm,
    required double windAdjustedRangeKm,
  }) {
    final rangeDifferenceKm = windAdjustedRangeKm - stillAirRangeKm;

    if (rangeDifferenceKm.abs() < 0.05) {
      return 'Sakin hava ve yer hızı koşullarında tahmini havada kalış '
          'süresi ${enduranceMinutes.toStringAsFixed(1)} dakika, menzil '
          '${stillAirRangeKm.toStringAsFixed(1)} km değerindedir.';
    }

    final windEffect = rangeDifferenceKm > 0.0
        ? 'arka rüzgâr menzili artırmıştır'
        : 'karşı rüzgâr menzili azaltmıştır';

    return 'Tahmini havada kalış süresi '
        '${enduranceMinutes.toStringAsFixed(1)} dakikadır. '
        'Sakin hava menzili ${stillAirRangeKm.toStringAsFixed(1)} km, '
        'rüzgâr düzeltilmiş menzil '
        '${windAdjustedRangeKm.toStringAsFixed(1)} km değerindedir; '
        '$windEffect.';
  }
}
