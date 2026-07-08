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
aspect_ratio_service.dart

Description

Bu servis sabit kanat hava araçları için Aspect Ratio değerini hesaplar.

Aspect Ratio, kanadın geometrik verimliliğini gösteren önemli
bir aerodinamik parametredir.

Formula

AR = b² / S

Inputs

b = Wing Span / Kanat Açıklığı (m)
S = Wing Area / Kanat Alanı (m²)

Output

AR = Aspect Ratio

====================================================================
*/

class AspectRatioService {
  double calculate({required double wingSpanM, required double wingAreaM2}) {
    if (wingAreaM2 <= 0) {
      return 0;
    }

    return (wingSpanM * wingSpanM) / wingAreaM2;
  }
}
