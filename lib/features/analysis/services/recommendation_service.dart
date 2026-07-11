class RecommendationService {
  String generate({
    required String aircraftType,
    required bool hasFixedWingAerodynamics,
    required double wingLoading,
    required double stallSpeed,
    required double powerToWeight,
    required double thrustToWeight,
  }) {
    final recommendations = <String>[];

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
}
