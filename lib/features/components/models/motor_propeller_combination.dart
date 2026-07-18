class MotorPropellerPerformancePoint {
  final double voltageV;
  final double throttlePercent;
  final double currentA;
  final double electricalPowerW;
  final double thrustN;
  final double rpm;
  final double efficiencyGramPerWatt;

  MotorPropellerPerformancePoint({
    required this.voltageV,
    required this.throttlePercent,
    required this.currentA,
    required this.electricalPowerW,
    required this.thrustN,
    required this.rpm,
    required this.efficiencyGramPerWatt,
  }) {
    if (voltageV <= 0) {
      throw ArgumentError.value(
        voltageV,
        'voltageV',
        'Test voltajı sıfırdan büyük olmalıdır.',
      );
    }

    if (throttlePercent < 0 || throttlePercent > 100) {
      throw ArgumentError.value(
        throttlePercent,
        'throttlePercent',
        'Throttle yüzdesi 0 ile 100 arasında olmalıdır.',
      );
    }

    if (currentA < 0) {
      throw ArgumentError.value(currentA, 'currentA', 'Akım negatif olamaz.');
    }

    if (electricalPowerW < 0) {
      throw ArgumentError.value(
        electricalPowerW,
        'electricalPowerW',
        'Elektriksel güç negatif olamaz.',
      );
    }

    if (thrustN < 0) {
      throw ArgumentError.value(thrustN, 'thrustN', 'İtki negatif olamaz.');
    }

    if (rpm < 0) {
      throw ArgumentError.value(rpm, 'rpm', 'RPM negatif olamaz.');
    }

    if (efficiencyGramPerWatt < 0) {
      throw ArgumentError.value(
        efficiencyGramPerWatt,
        'efficiencyGramPerWatt',
        'Verim değeri negatif olamaz.',
      );
    }
  }

  double get thrustGram => thrustN / 9.80665 * 1000.0;

  double get calculatedElectricalPowerW => voltageV * currentA;

  double get powerDifferenceW => electricalPowerW - calculatedElectricalPowerW;

  MotorPropellerPerformancePoint copyWith({
    double? voltageV,
    double? throttlePercent,
    double? currentA,
    double? electricalPowerW,
    double? thrustN,
    double? rpm,
    double? efficiencyGramPerWatt,
  }) {
    return MotorPropellerPerformancePoint(
      voltageV: voltageV ?? this.voltageV,
      throttlePercent: throttlePercent ?? this.throttlePercent,
      currentA: currentA ?? this.currentA,
      electricalPowerW: electricalPowerW ?? this.electricalPowerW,
      thrustN: thrustN ?? this.thrustN,
      rpm: rpm ?? this.rpm,
      efficiencyGramPerWatt:
          efficiencyGramPerWatt ?? this.efficiencyGramPerWatt,
    );
  }

  Map<String, Object> toMap() {
    return {
      'voltageV': voltageV,
      'throttlePercent': throttlePercent,
      'currentA': currentA,
      'electricalPowerW': electricalPowerW,
      'thrustN': thrustN,
      'rpm': rpm,
      'efficiencyGramPerWatt': efficiencyGramPerWatt,
    };
  }

  factory MotorPropellerPerformancePoint.fromMap(Map<String, Object?> map) {
    return MotorPropellerPerformancePoint(
      voltageV: (map['voltageV']! as num).toDouble(),
      throttlePercent: (map['throttlePercent']! as num).toDouble(),
      currentA: (map['currentA']! as num).toDouble(),
      electricalPowerW: (map['electricalPowerW']! as num).toDouble(),
      thrustN: (map['thrustN']! as num).toDouble(),
      rpm: (map['rpm']! as num).toDouble(),
      efficiencyGramPerWatt: (map['efficiencyGramPerWatt']! as num).toDouble(),
    );
  }
}

class MotorPropellerCombination {
  final String id;
  final String motorComponentId;
  final String propellerComponentId;
  final String dataSource;
  final String testDate;
  final String testConditions;
  final List<MotorPropellerPerformancePoint> performancePoints;
  final String notes;

  MotorPropellerCombination({
    required this.id,
    required this.motorComponentId,
    required this.propellerComponentId,
    required this.dataSource,
    required this.testDate,
    required this.testConditions,
    required List<MotorPropellerPerformancePoint> performancePoints,
    this.notes = '',
  }) : performancePoints = List.unmodifiable(performancePoints) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Kombinasyon kimliği boş olamaz.');
    }

    if (motorComponentId.trim().isEmpty) {
      throw ArgumentError.value(
        motorComponentId,
        'motorComponentId',
        'Motor komponent kimliği boş olamaz.',
      );
    }

    if (propellerComponentId.trim().isEmpty) {
      throw ArgumentError.value(
        propellerComponentId,
        'propellerComponentId',
        'Pervane komponent kimliği boş olamaz.',
      );
    }

    if (dataSource.trim().isEmpty) {
      throw ArgumentError.value(
        dataSource,
        'dataSource',
        'Performans verisinin kaynağı boş olamaz.',
      );
    }

    if (testDate.trim().isEmpty) {
      throw ArgumentError.value(
        testDate,
        'testDate',
        'Test tarihi boş olamaz.',
      );
    }

    if (testConditions.trim().isEmpty) {
      throw ArgumentError.value(
        testConditions,
        'testConditions',
        'Test koşulları boş olamaz.',
      );
    }

    if (performancePoints.isEmpty) {
      throw ArgumentError(
        'Motor-pervane kombinasyonu en az bir performans noktası içermelidir.',
      );
    }

    for (var index = 1; index < performancePoints.length; index++) {
      final previousThrottle = performancePoints[index - 1].throttlePercent;
      final currentThrottle = performancePoints[index].throttlePercent;

      if (currentThrottle <= previousThrottle) {
        throw ArgumentError(
          'Performans noktaları artan throttle sırasıyla verilmelidir.',
        );
      }
    }
  }

  MotorPropellerPerformancePoint get minimumThrottlePoint =>
      performancePoints.first;

  MotorPropellerPerformancePoint get maximumThrottlePoint =>
      performancePoints.last;

  double get maximumThrustN => performancePoints
      .map((point) => point.thrustN)
      .reduce((first, second) => first > second ? first : second);

  double get maximumCurrentA => performancePoints
      .map((point) => point.currentA)
      .reduce((first, second) => first > second ? first : second);

  double get maximumElectricalPowerW => performancePoints
      .map((point) => point.electricalPowerW)
      .reduce((first, second) => first > second ? first : second);

  MotorPropellerPerformancePoint? findExactThrottle(double throttlePercent) {
    for (final point in performancePoints) {
      if ((point.throttlePercent - throttlePercent).abs() < 0.0001) {
        return point;
      }
    }

    return null;
  }

  MotorPropellerPerformancePoint nearestThrottle(double throttlePercent) {
    if (throttlePercent < 0 || throttlePercent > 100) {
      throw ArgumentError.value(
        throttlePercent,
        'throttlePercent',
        'Throttle yüzdesi 0 ile 100 arasında olmalıdır.',
      );
    }

    var nearestPoint = performancePoints.first;
    var nearestDifference = (nearestPoint.throttlePercent - throttlePercent)
        .abs();

    for (final point in performancePoints.skip(1)) {
      final difference = (point.throttlePercent - throttlePercent).abs();

      if (difference < nearestDifference) {
        nearestPoint = point;
        nearestDifference = difference;
      }
    }

    return nearestPoint;
  }

  MotorPropellerCombination copyWith({
    String? id,
    String? motorComponentId,
    String? propellerComponentId,
    String? dataSource,
    String? testDate,
    String? testConditions,
    List<MotorPropellerPerformancePoint>? performancePoints,
    String? notes,
  }) {
    return MotorPropellerCombination(
      id: id ?? this.id,
      motorComponentId: motorComponentId ?? this.motorComponentId,
      propellerComponentId: propellerComponentId ?? this.propellerComponentId,
      dataSource: dataSource ?? this.dataSource,
      testDate: testDate ?? this.testDate,
      testConditions: testConditions ?? this.testConditions,
      performancePoints: performancePoints ?? this.performancePoints,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'motorComponentId': motorComponentId,
      'propellerComponentId': propellerComponentId,
      'dataSource': dataSource,
      'testDate': testDate,
      'testConditions': testConditions,
      'performancePoints': performancePoints
          .map((point) => point.toMap())
          .toList(),
      'notes': notes,
    };
  }

  factory MotorPropellerCombination.fromMap(Map<String, Object?> map) {
    final rawPoints = map['performancePoints']! as List<Object?>;

    return MotorPropellerCombination(
      id: map['id']! as String,
      motorComponentId: map['motorComponentId']! as String,
      propellerComponentId: map['propellerComponentId']! as String,
      dataSource: map['dataSource']! as String,
      testDate: map['testDate']! as String,
      testConditions: map['testConditions']! as String,
      performancePoints: rawPoints
          .map(
            (point) => MotorPropellerPerformancePoint.fromMap(
              Map<String, Object?>.from(point! as Map),
            ),
          )
          .toList(),
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
