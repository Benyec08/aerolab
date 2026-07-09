class RecommendationService {
  String generate({
    required double wingLoading,
    required double stallSpeed,
    required double powerToWeight,
    required double thrustToWeight,
  }) {
    final recommendations = <String>[];

    if (wingLoading < 6) {
      recommendations.add('✓ Wing loading değeri ideal seviyede.');
    } else {
      recommendations.add('⚠ Wing loading yüksek. Kanat alanı artırılabilir.');
    }

    if (stallSpeed < 10) {
      recommendations.add('✓ Stall hızı güvenli sınırlar içerisinde.');
    } else {
      recommendations.add(
        '⚠ Stall hızı yüksek. Düşük hız performansı iyileştirilebilir.',
      );
    }

    if (powerToWeight > 250) {
      recommendations.add('✓ Güç / Ağırlık oranı oldukça iyi.');
    } else {
      recommendations.add('⚠ Motor gücü artırılabilir.');
    }

    if (thrustToWeight > 2) {
      recommendations.add('✓ Kalkış performansı oldukça güçlü.');
    } else {
      recommendations.add('⚠ İtki / Ağırlık oranı geliştirilebilir.');
    }

    return recommendations.join('\n');
  }
}
