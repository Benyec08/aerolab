/// Desteklenen batarya kimyaları için hücre bazlı elektriksel
/// karakteristikleri sağlar.
///
/// Voltaj değerleri tek hücre içindir.
/// Paket voltajları hücre sayısıyla çarpılarak hesaplanır.
class BatteryChemistryService {
  BatteryChemistryProfile getProfile(String batteryType) {
    final normalizedType = batteryType
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    switch (normalizedType) {
      case 'lipo':
        return const BatteryChemistryProfile(
          chemistryName: 'LiPo',
          fullCellVoltageV: 4.20,
          nominalCellVoltageV: 3.70,
          minimumSafeCellVoltageV: 3.30,
          defaultCellInternalResistanceMilliOhm: 4.0,
          recommendedContinuousCRate: 20.0,
          recommendedPeakCRate: 35.0,
        );

      case 'liion':
      case 'lion':
        return const BatteryChemistryProfile(
          chemistryName: 'Li-Ion',
          fullCellVoltageV: 4.20,
          nominalCellVoltageV: 3.60,
          minimumSafeCellVoltageV: 3.00,
          defaultCellInternalResistanceMilliOhm: 18.0,
          recommendedContinuousCRate: 3.0,
          recommendedPeakCRate: 5.0,
        );

      case 'lihv':
        return const BatteryChemistryProfile(
          chemistryName: 'LiHV',
          fullCellVoltageV: 4.35,
          nominalCellVoltageV: 3.80,
          minimumSafeCellVoltageV: 3.30,
          defaultCellInternalResistanceMilliOhm: 4.5,
          recommendedContinuousCRate: 20.0,
          recommendedPeakCRate: 35.0,
        );

      default:
        throw ArgumentError.value(
          batteryType,
          'batteryType',
          'Desteklenmeyen batarya tipi. '
              'Desteklenen tipler: LiPo, Li-Ion ve LiHV.',
        );
    }
  }
}

class BatteryChemistryProfile {
  final String chemistryName;

  /// Tam dolu hücrenin açık devre voltajı.
  final double fullCellVoltageV;

  /// Hücrenin üretici tarafından belirtilen nominal voltajı.
  final double nominalCellVoltageV;

  /// Yük altında inilmemesi gereken minimum güvenli hücre voltajı.
  final double minimumSafeCellVoltageV;

  /// Kullanıcı değeri bulunmadığında kullanılabilecek hücre başına
  /// varsayılan iç direnç.
  final double defaultCellInternalResistanceMilliOhm;

  /// Kimya için referans sürekli deşarj oranı.
  final double recommendedContinuousCRate;

  /// Kimya için referans kısa süreli peak deşarj oranı.
  final double recommendedPeakCRate;

  const BatteryChemistryProfile({
    required this.chemistryName,
    required this.fullCellVoltageV,
    required this.nominalCellVoltageV,
    required this.minimumSafeCellVoltageV,
    required this.defaultCellInternalResistanceMilliOhm,
    required this.recommendedContinuousCRate,
    required this.recommendedPeakCRate,
  });

  double fullPackVoltageV(int cellCount) {
    _validateCellCount(cellCount);
    return fullCellVoltageV * cellCount;
  }

  double nominalPackVoltageV(int cellCount) {
    _validateCellCount(cellCount);
    return nominalCellVoltageV * cellCount;
  }

  double minimumSafePackVoltageV(int cellCount) {
    _validateCellCount(cellCount);
    return minimumSafeCellVoltageV * cellCount;
  }

  void _validateCellCount(int cellCount) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }
  }
}
