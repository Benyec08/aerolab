class AnalysisResult {
  final double liftN;
  final double dragN;
  final double wingLoading;
  final double stallSpeed;
  final double thrustToWeight;
  final double estimatedFlightTime;
  final double aspectRatio;
  final double powerToWeight;
  final double estimatedThrustN;

  final String wingLoadingStatus;
  final String powerToWeightStatus;
  final String thrustToWeightStatus;

  final int riskScore;
  final String status;
  final String recommendation;

  const AnalysisResult({
    required this.liftN,
    required this.dragN,
    required this.wingLoading,
    required this.stallSpeed,
    required this.thrustToWeight,
    required this.estimatedFlightTime,
    required this.aspectRatio,
    required this.powerToWeight,
    required this.estimatedThrustN,
    required this.wingLoadingStatus,
    required this.powerToWeightStatus,
    required this.thrustToWeightStatus,
    required this.riskScore,
    required this.status,
    required this.recommendation,
  });
}
