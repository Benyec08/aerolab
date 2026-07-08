/*
====================================================================

Project
AeroLab

Version
v0.2.0

Sprint
5

Module
Aircraft Performance

File
power_to_weight_service.dart

Author
Yunus Emre Ceylan

Description

Bu servis güç/ağırlık oranını hesaplar.

Power-to-Weight Ratio, hava aracının motor gücünün
toplam ağırlığa göre yeterli olup olmadığını değerlendirmek için kullanılır.

Formula

Power-to-Weight = Motor Power / Weight

Inputs

Motor Power (W)

Weight (kg)

Output

Power-to-Weight Ratio (W/kg)

====================================================================
*/

class PowerToWeightService {
  double calculate({required double motorPowerW, required double weightKg}) {
    if (weightKg <= 0) {
      return 0;
    }

    return motorPowerW / weightKg;
  }

  String evaluate(double powerToWeight) {
    if (powerToWeight < 150) {
      return 'Zayıf';
    }

    if (powerToWeight < 250) {
      return 'Orta';
    }

    if (powerToWeight < 400) {
      return 'İyi';
    }

    return 'Çok İyi';
  }
}
