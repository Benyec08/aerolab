class StabilityResult {
  final bool isApplicable;
  final double centerOfGravityFromLeadingEdgeM;
  final double centerOfGravityPercentMac;
  final double neutralPointFromLeadingEdgeM;
  final double neutralPointPercentMac;
  final double staticMarginPercent;
  final bool isCenterOfGravityWithinLimits;
  final bool isStaticallyStable;
  final String status;
  final String message;

  const StabilityResult({
    required this.isApplicable,
    required this.centerOfGravityFromLeadingEdgeM,
    required this.centerOfGravityPercentMac,
    required this.neutralPointFromLeadingEdgeM,
    required this.neutralPointPercentMac,
    required this.staticMarginPercent,
    required this.isCenterOfGravityWithinLimits,
    required this.isStaticallyStable,
    required this.status,
    required this.message,
  });

  const StabilityResult.notApplicable({
    this.status = 'Uygulanamaz',
    this.message =
        'Ağırlık merkezi ve statik marj bu araç tipi veya mevcut girdiler '
        'için hesaplanamadı.',
  }) : isApplicable = false,
       centerOfGravityFromLeadingEdgeM = 0.0,
       centerOfGravityPercentMac = 0.0,
       neutralPointFromLeadingEdgeM = 0.0,
       neutralPointPercentMac = 0.0,
       staticMarginPercent = 0.0,
       isCenterOfGravityWithinLimits = false,
       isStaticallyStable = false;

  bool get hasPositiveStaticMargin => isApplicable && staticMarginPercent > 0.0;

  Map<String, Object> toMap() {
    return {
      'isApplicable': isApplicable,
      'centerOfGravityFromLeadingEdgeM': centerOfGravityFromLeadingEdgeM,
      'centerOfGravityPercentMac': centerOfGravityPercentMac,
      'neutralPointFromLeadingEdgeM': neutralPointFromLeadingEdgeM,
      'neutralPointPercentMac': neutralPointPercentMac,
      'staticMarginPercent': staticMarginPercent,
      'isCenterOfGravityWithinLimits': isCenterOfGravityWithinLimits,
      'isStaticallyStable': isStaticallyStable,
      'status': status,
      'message': message,
    };
  }

  factory StabilityResult.fromMap(Map<String, Object?> map) {
    return StabilityResult(
      isApplicable: map['isApplicable']! as bool,
      centerOfGravityFromLeadingEdgeM:
          (map['centerOfGravityFromLeadingEdgeM']! as num).toDouble(),
      centerOfGravityPercentMac: (map['centerOfGravityPercentMac']! as num)
          .toDouble(),
      neutralPointFromLeadingEdgeM:
          (map['neutralPointFromLeadingEdgeM']! as num).toDouble(),
      neutralPointPercentMac: (map['neutralPointPercentMac']! as num)
          .toDouble(),
      staticMarginPercent: (map['staticMarginPercent']! as num).toDouble(),
      isCenterOfGravityWithinLimits:
          map['isCenterOfGravityWithinLimits']! as bool,
      isStaticallyStable: map['isStaticallyStable']! as bool,
      status: map['status']! as String,
      message: map['message']! as String,
    );
  }
}
