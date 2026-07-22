class RiskService {
  int calculateRiskScore({
    required double windSpeedKmh,
    required double thrustToWeight,
    required bool evaluateFixedWingAerodynamics,
    required double wingLoading,
    required double flightSpeedMs,
    required double stallSpeedMs,
    bool isAtmosphereWithinSupportedLimits = true,
    bool isWindWithinSupportedLimits = true,
    bool hasSufficientInstalledPower = true,
    bool isPropulsionSystemSafe = true,
    bool isBatterySystemSafe = true,
    bool isStabilityApplicable = false,
    bool isCenterOfGravityWithinLimits = true,
    bool isStaticallyStable = true,
    double staticMarginPercent = 100.0,
    bool isFlightEnvelopeApplicable = false,
    bool isCruiseInsideEnvelope = true,
    bool usesComponentDatabase = false,
    bool isComponentSelectionCompatible = true,
  }) {
    int score = 100;

    if (windSpeedKmh > 20) {
      score -= 20;
    }

    if (thrustToWeight < 1.0) {
      score -= 30;
    }

    if (evaluateFixedWingAerodynamics) {
      if (wingLoading > 70) {
        score -= 20;
      }

      if (flightSpeedMs <= stallSpeedMs) {
        score -= 35;
      }
    }

    if (!isAtmosphereWithinSupportedLimits) {
      score -= 20;
    }

    if (!isWindWithinSupportedLimits) {
      score -= 20;
    }

    if (!hasSufficientInstalledPower) {
      score -= 30;
    }

    if (!isPropulsionSystemSafe) {
      score -= 30;
    }

    if (!isBatterySystemSafe) {
      score -= 30;
    }

    if (isStabilityApplicable) {
      if (!isStaticallyStable) {
        score -= 55;
      } else if (!isCenterOfGravityWithinLimits) {
        score -= 45;
      } else if (staticMarginPercent < 5.0) {
        score -= 20;
      }
    }

    if (isFlightEnvelopeApplicable && !isCruiseInsideEnvelope) {
      score -= 45;
    }

    if (usesComponentDatabase && !isComponentSelectionCompatible) {
      score -= 25;
    }

    if (score < 0) {
      return 0;
    }

    if (score > 100) {
      return 100;
    }

    return score;
  }

  String getStatus(int riskScore) {
    if (riskScore >= 80) {
      return 'Güvenli';
    }

    if (riskScore >= 60) {
      return 'Dikkat';
    }

    return 'Riskli';
  }
}
