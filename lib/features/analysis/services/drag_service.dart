class DragService {
  double calculate({
    required double airDensity,
    required double velocityMs,
    required double wingAreaM2,
    required double dragCoefficient,
  }) {
    _validatePositiveFinite(airDensity, 'airDensity');
    _validateNonNegativeFinite(velocityMs, 'velocityMs');
    _validatePositiveFinite(wingAreaM2, 'wingAreaM2');
    _validateNonNegativeFinite(dragCoefficient, 'dragCoefficient');

    return 0.5 *
        airDensity *
        velocityMs *
        velocityMs *
        wingAreaM2 *
        dragCoefficient;
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

  void _validateNonNegativeFinite(double value, String name) {
    if (!value.isFinite || value < 0.0) {
      throw ArgumentError.value(
        value,
        name,
        'Değer negatif olmamalı ve sonlu olmalıdır.',
      );
    }
  }
}
