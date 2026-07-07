class DragService {
  double calculate({
    required double airDensity,
    required double velocityMs,
    required double wingAreaM2,
    required double dragCoefficient,
  }) {
    return 0.5 *
        airDensity *
        velocityMs *
        velocityMs *
        wingAreaM2 *
        dragCoefficient;
  }
}