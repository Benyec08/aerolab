import 'dart:math';

class StallService {
  double calculate({
    required double weightKg,
    required double wingAreaM2,
    required double airDensity,
    required double clMax,
  }) {
    _validatePositiveFinite(weightKg, 'weightKg');
    _validatePositiveFinite(wingAreaM2, 'wingAreaM2');
    _validatePositiveFinite(airDensity, 'airDensity');
    _validatePositiveFinite(clMax, 'clMax');

    final weightNewton = weightKg * 9.81;

    return sqrt((2.0 * weightNewton) / (airDensity * wingAreaM2 * clMax));
  }

  void _validatePositiveFinite(double value, String name) {
    if (!value.isFinite || value <= 0.0) {
      throw ArgumentError.value(
        value,
        name,
        'Değer sıfırdan büyük ve sonlu olmalıdır.',
      );
    }
  }
}
