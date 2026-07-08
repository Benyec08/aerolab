/*
====================================================================

Project
AeroLab

Sprint
4

Module
Battery Engineering

File
battery_validation_service.dart

Description

Bu servis batarya tipi ve hücre sayısına göre beklenen nominal
voltaj değerini hesaplar ve kullanıcının girdiği voltajın mantıklı
olup olmadığını kontrol eder.

====================================================================
*/

class BatteryValidationService {
  double nominalCellVoltage(String batteryType) {
    switch (batteryType) {
      case 'Li-Ion':
        return 3.6;
      case 'LiHV':
        return 3.8;
      case 'LiPo':
      default:
        return 3.7;
    }
  }

  double expectedVoltage({
    required String batteryType,
    required int cellCount,
  }) {
    return nominalCellVoltage(batteryType) * cellCount;
  }

  bool isVoltageValid({
    required String batteryType,
    required int cellCount,
    required double enteredVoltage,
  }) {
    final expected = expectedVoltage(
      batteryType: batteryType,
      cellCount: cellCount,
    );

    final difference = (enteredVoltage - expected).abs();

    return difference <= 1.0;
  }
}
