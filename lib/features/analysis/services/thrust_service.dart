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
thrust_service.dart

Author
Yunus Emre Ceylan

Description

Bu servis toplam tahmini itkiyi hesaplar.

İlk sürümde yaklaşık mühendislik modeli
kullanılmaktadır.

Formula

Estimated Thrust = Motor Power × 0.18 × Motor Count

Output

Estimated Total Thrust (Newton)

====================================================================
*/

class ThrustService {
  double calculate({required double motorPowerW, required int motorCount}) {
    return motorPowerW * 0.18 * motorCount;
  }

  double thrustToWeight({required double thrustN, required double weightKg}) {
    if (weightKg <= 0) {
      return 0;
    }

    return thrustN / (weightKg * 9.81);
  }

  String evaluate(double ratio) {
    if (ratio < 0.8) {
      return 'Yetersiz';
    }

    if (ratio < 1.2) {
      return 'Yeterli';
    }

    if (ratio < 2.0) {
      return 'İyi';
    }

    return 'Çok Güçlü';
  }
}
