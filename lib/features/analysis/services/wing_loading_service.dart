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
wing_loading_service.dart

Author
Yunus Emre Ceylan

Description

Bu servis kanat yüklemesini (Wing Loading) hesaplar.

Wing Loading hava aracının performansını belirleyen
en önemli aerodinamik parametrelerden biridir.

Formula

Wing Loading = Weight / Wing Area

Inputs

Weight (kg)

Wing Area (m²)

Output

Wing Loading (kg/m²)

====================================================================
*/

class WingLoadingService {
  double calculate({required double weightKg, required double wingAreaM2}) {
    if (wingAreaM2 <= 0) {
      return 0;
    }

    return weightKg / wingAreaM2;
  }

  String evaluate(double wingLoading) {
    if (wingLoading < 4) {
      return 'Çok Düşük';
    }

    if (wingLoading < 8) {
      return 'İyi';
    }

    if (wingLoading < 12) {
      return 'Orta';
    }

    if (wingLoading < 16) {
      return 'Yüksek';
    }

    return 'Çok Yüksek';
  }
}
