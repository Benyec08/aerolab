class LiftService {
  double calculate({
    required double airDensity,
    required double velocityMs,
    required double wingAreaM2,
    required double liftCoefficient,
  }) {
    return 0.5 *
        airDensity *
        velocityMs *
        velocityMs *
        wingAreaM2 *
        liftCoefficient;
  }
}
