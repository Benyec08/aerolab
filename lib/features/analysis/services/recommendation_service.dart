class RecommendationService {
  String generate({
    required String aircraftType,
    required bool hasFixedWingAerodynamics,
    required double wingLoading,
    required double stallSpeed,
    required double powerToWeight,
    required double thrustToWeight,
    String atmosphereStatus = 'Normal Atmosfer',
    bool isAtmosphereWithinSupportedLimits = true,
    double densityAltitudeDifferenceM = 0.0,
    double densityDeviationPercent = 0.0,
    double temperatureDeviationC = 0.0,
    String windSafetyStatus = 'Güvenli - sakin hava',
    bool isWindWithinSupportedLimits = true,
    double headwindComponentMs = 0.0,
    double tailwindComponentMs = 0.0,
    double crosswindComponentMs = 0.0,
  }) {
    final recommendations = <String>[];

    _addAtmosphereRecommendations(
      recommendations: recommendations,
      atmosphereStatus: atmosphereStatus,
      isAtmosphereWithinSupportedLimits: isAtmosphereWithinSupportedLimits,
      densityAltitudeDifferenceM: densityAltitudeDifferenceM,
      densityDeviationPercent: densityDeviationPercent,
      temperatureDeviationC: temperatureDeviationC,
    );

    _addWindRecommendations(
      recommendations: recommendations,
      windSafetyStatus: windSafetyStatus,
      isWindWithinSupportedLimits: isWindWithinSupportedLimits,
      headwindComponentMs: headwindComponentMs,
      tailwindComponentMs: tailwindComponentMs,
      crosswindComponentMs: crosswindComponentMs,
    );

    if (hasFixedWingAerodynamics) {
      if (wingLoading < 6) {
        recommendations.add('✓ Wing loading değeri ideal seviyede.');
      } else {
        recommendations.add(
          '⚠ Wing loading yüksek. Kanat alanı artırılabilir.',
        );
      }

      if (stallSpeed < 10) {
        recommendations.add('✓ Stall hızı güvenli sınırlar içerisinde.');
      } else {
        recommendations.add(
          '⚠ Stall hızı yüksek. Düşük hız performansı iyileştirilebilir.',
        );
      }
    } else {
      recommendations.add(
        'ℹ $aircraftType için sabit kanat lift, wing loading ve stall '
        'metrikleri uygulanmaz.',
      );
    }

    if (powerToWeight > 250) {
      recommendations.add('✓ Güç / Ağırlık oranı oldukça iyi.');
    } else {
      recommendations.add('⚠ Motor gücü artırılabilir.');
    }

    if (thrustToWeight > 2) {
      recommendations.add('✓ İtki / Ağırlık oranı güçlü.');
    } else if (thrustToWeight >= 1.2) {
      recommendations.add('✓ İtki / Ağırlık oranı yeterli.');
    } else {
      recommendations.add('⚠ İtki / Ağırlık oranı geliştirilebilir.');
    }

    return recommendations.join('\n');
  }

  void _addAtmosphereRecommendations({
    required List<String> recommendations,
    required String atmosphereStatus,
    required bool isAtmosphereWithinSupportedLimits,
    required double densityAltitudeDifferenceM,
    required double densityDeviationPercent,
    required double temperatureDeviationC,
  }) {
    if (!isAtmosphereWithinSupportedLimits) {
      recommendations.add(
        '⛔ Atmosfer koşulları desteklenen analiz sınırlarının dışında.',
      );
      return;
    }

    if (densityAltitudeDifferenceM >= 1500) {
      recommendations.add(
        '⛔ Yoğunluk irtifası geometrik irtifadan çok yüksek. '
        'Kaldırma, itki ve kalkış performansı ciddi biçimde azalabilir.',
      );
    } else if (densityAltitudeDifferenceM >= 500) {
      recommendations.add(
        '⚠ Yoğunluk irtifası yüksek. Uçuş performansında azalma beklenir.',
      );
    }

    if (densityDeviationPercent <= -15) {
      recommendations.add(
        '⛔ Hava yoğunluğu ISA değerinin belirgin altında. '
        'Ek güç ve hız marjı değerlendirilmelidir.',
      );
    } else if (densityDeviationPercent <= -7) {
      recommendations.add(
        '⚠ Düşük hava yoğunluğu aerodinamik ve itki performansını azaltabilir.',
      );
    }

    if (temperatureDeviationC.abs() >= 25) {
      recommendations.add(
        '⚠ ISA sıcaklık sapması çok yüksek '
        '(${temperatureDeviationC.toStringAsFixed(1)} °C).',
      );
    } else if (temperatureDeviationC.abs() >= 15) {
      recommendations.add(
        '⚠ ISA sıcaklık sapması yüksek '
        '(${temperatureDeviationC.toStringAsFixed(1)} °C).',
      );
    }

    final normalizedStatus = atmosphereStatus.toLowerCase();
    final hasCriticalStatus =
        normalizedStatus.contains('kritik') ||
        normalizedStatus.contains('yüksek risk');

    if (hasCriticalStatus &&
        densityAltitudeDifferenceM < 500 &&
        densityDeviationPercent > -7) {
      recommendations.add('⚠ Atmosfer durumu: $atmosphereStatus.');
    }
  }

  void _addWindRecommendations({
    required List<String> recommendations,
    required String windSafetyStatus,
    required bool isWindWithinSupportedLimits,
    required double headwindComponentMs,
    required double tailwindComponentMs,
    required double crosswindComponentMs,
  }) {
    if (!isWindWithinSupportedLimits) {
      recommendations.add(
        '⛔ Rüzgâr koşulları desteklenen analiz sınırlarının dışında.',
      );
      return;
    }

    if (tailwindComponentMs >= 8) {
      recommendations.add(
        '⛔ Kritik arka rüzgâr. Etkin hava hızı ve stall marjı '
        'kontrol edilmelidir.',
      );
    } else if (tailwindComponentMs >= 4) {
      recommendations.add('⚠ Arka rüzgâr etkin hava hızını azaltabilir.');
    }

    if (headwindComponentMs >= 10) {
      recommendations.add(
        '⚠ Güçlü karşı rüzgâr yer hızını ve görev süresini azaltabilir.',
      );
    } else if (headwindComponentMs >= 5) {
      recommendations.add(
        '⚠ Karşı rüzgâr nedeniyle görev süresi ve menzil azalabilir.',
      );
    }

    if (crosswindComponentMs >= 8) {
      recommendations.add(
        '⛔ Kritik çapraz rüzgâr. Yanal kontrol ve operasyon güvenliği '
        'değerlendirilmelidir.',
      );
    } else if (crosswindComponentMs >= 4) {
      recommendations.add('⚠ Çapraz rüzgâr yanal kontrol marjını azaltabilir.');
    }

    final normalizedStatus = windSafetyStatus.toLowerCase();
    final hasCriticalStatus =
        normalizedStatus.contains('kritik') ||
        normalizedStatus.contains('yüksek risk');

    final hasComponentWarning =
        headwindComponentMs >= 5 ||
        tailwindComponentMs >= 4 ||
        crosswindComponentMs >= 4;

    if (hasCriticalStatus && !hasComponentWarning) {
      recommendations.add('⚠ Rüzgâr güvenlik durumu: $windSafetyStatus.');
    }
  }
}
