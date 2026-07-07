/*
====================================================================

Project
AeroLab

Module
Aerodynamics Engine

File
risk_service.dart

Description

Bu servis analiz sonuçlarına göre temel risk skoru üretir.

Risk skoru 100 üzerinden hesaplanır.
Yüksek skor daha güvenli, düşük skor daha riskli anlamına gelir.

Bu sürümde temel kural tabanlı risk analizi yapılmaktadır.
İleride daha gelişmiş karar destek sistemi eklenecektir.

====================================================================
*/

class RiskService {
  int calculateRiskScore({
    required double windSpeedKmh,
    required double thrustToWeight,
    required double wingLoading,
    required double flightSpeedMs,
    required double stallSpeedMs,
  }) {
    int score = 100;

    //--------------------------------------------------------------
    // Rüzgar kontrolü
    //--------------------------------------------------------------

    if (windSpeedKmh > 20) {
      score -= 20;
    }

    //--------------------------------------------------------------
    // İtki / ağırlık oranı kontrolü
    //--------------------------------------------------------------

    if (thrustToWeight < 1.0) {
      score -= 30;
    }

    //--------------------------------------------------------------
    // Kanat yüklemesi kontrolü
    //--------------------------------------------------------------

    if (wingLoading > 70) {
      score -= 20;
    }

    //--------------------------------------------------------------
    // Stall riski kontrolü
    //--------------------------------------------------------------

    if (flightSpeedMs <= stallSpeedMs) {
      score -= 35;
    }

    //--------------------------------------------------------------
    // Skorun 0 altına düşmesini engelle
    //--------------------------------------------------------------

    if (score < 0) {
      score = 0;
    }

    return score;
  }

  String getStatus(int riskScore) {
    if (riskScore >= 80) {
      return 'Güvenli';
    } else if (riskScore >= 60) {
      return 'Dikkat';
    } else {
      return 'Riskli';
    }
  }

  String getRecommendation({
    required int riskScore,
    required double windSpeedKmh,
    required double flightSpeedMs,
    required double stallSpeedMs,
  }) {
    if (riskScore >= 80) {
      return 'Mevcut değerlerle uçuş uygun görünmektedir.';
    }

    if (flightSpeedMs <= stallSpeedMs) {
      return 'Uçuş hızı stall hızının altında. Kalkış önerilmez.';
    }

    if (windSpeedKmh > 20) {
      return 'Rüzgar hızı yüksek. Daha sakin hava şartlarında analiz önerilir.';
    }

    return 'Bazı değerler sınırda. Uçuş öncesi tekrar kontrol önerilir.';
  }
}