class MotorComponent {
  final String id;
  final String manufacturer;
  final String model;
  final double kvRating;
  final double minimumVoltageV;
  final double maximumVoltageV;
  final double continuousPowerW;
  final double maximumPowerW;
  final double continuousCurrentA;
  final double maximumCurrentA;
  final double efficiency;
  final double weightG;
  final double minimumRecommendedPropellerDiameterInch;
  final double maximumRecommendedPropellerDiameterInch;
  final int minimumRecommendedCellCount;
  final int maximumRecommendedCellCount;
  final String notes;

  MotorComponent({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.kvRating,
    required this.minimumVoltageV,
    required this.maximumVoltageV,
    required this.continuousPowerW,
    required this.maximumPowerW,
    required this.continuousCurrentA,
    required this.maximumCurrentA,
    required this.efficiency,
    required this.weightG,
    required this.minimumRecommendedPropellerDiameterInch,
    required this.maximumRecommendedPropellerDiameterInch,
    required this.minimumRecommendedCellCount,
    required this.maximumRecommendedCellCount,
    this.notes = '',
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Motor kimliği boş olamaz.');
    }

    if (manufacturer.trim().isEmpty) {
      throw ArgumentError.value(
        manufacturer,
        'manufacturer',
        'Üretici adı boş olamaz.',
      );
    }

    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'Motor modeli boş olamaz.');
    }

    if (kvRating <= 0) {
      throw ArgumentError.value(
        kvRating,
        'kvRating',
        'KV değeri sıfırdan büyük olmalıdır.',
      );
    }

    if (minimumVoltageV <= 0 || maximumVoltageV <= 0) {
      throw ArgumentError('Motor voltaj değerleri sıfırdan büyük olmalıdır.');
    }

    if (minimumVoltageV > maximumVoltageV) {
      throw ArgumentError(
        'Minimum motor voltajı maksimum voltajdan büyük olamaz.',
      );
    }

    if (continuousPowerW <= 0 || maximumPowerW <= 0) {
      throw ArgumentError('Motor güç değerleri sıfırdan büyük olmalıdır.');
    }

    if (continuousPowerW > maximumPowerW) {
      throw ArgumentError(
        'Sürekli motor gücü maksimum motor gücünden büyük olamaz.',
      );
    }

    if (continuousCurrentA <= 0 || maximumCurrentA <= 0) {
      throw ArgumentError('Motor akım değerleri sıfırdan büyük olmalıdır.');
    }

    if (continuousCurrentA > maximumCurrentA) {
      throw ArgumentError(
        'Sürekli motor akımı maksimum motor akımından büyük olamaz.',
      );
    }

    if (efficiency <= 0 || efficiency > 1) {
      throw ArgumentError.value(
        efficiency,
        'efficiency',
        'Motor verimi 0 ile 1 arasında olmalıdır.',
      );
    }

    if (weightG <= 0) {
      throw ArgumentError.value(
        weightG,
        'weightG',
        'Motor ağırlığı sıfırdan büyük olmalıdır.',
      );
    }

    if (minimumRecommendedPropellerDiameterInch <= 0 ||
        maximumRecommendedPropellerDiameterInch <= 0) {
      throw ArgumentError('Önerilen pervane çapları sıfırdan büyük olmalıdır.');
    }

    if (minimumRecommendedPropellerDiameterInch >
        maximumRecommendedPropellerDiameterInch) {
      throw ArgumentError(
        'Minimum pervane çapı maksimum pervane çapından büyük olamaz.',
      );
    }

    if (minimumRecommendedCellCount <= 0 || maximumRecommendedCellCount <= 0) {
      throw ArgumentError('Önerilen hücre sayıları sıfırdan büyük olmalıdır.');
    }

    if (minimumRecommendedCellCount > maximumRecommendedCellCount) {
      throw ArgumentError(
        'Minimum hücre sayısı maksimum hücre sayısından büyük olamaz.',
      );
    }
  }

  String get displayName => '$manufacturer $model';

  bool supportsVoltage(double voltageV) {
    return voltageV >= minimumVoltageV && voltageV <= maximumVoltageV;
  }

  bool supportsCellCount(int cellCount) {
    return cellCount >= minimumRecommendedCellCount &&
        cellCount <= maximumRecommendedCellCount;
  }

  bool supportsPropellerDiameter(double diameterInch) {
    return diameterInch >= minimumRecommendedPropellerDiameterInch &&
        diameterInch <= maximumRecommendedPropellerDiameterInch;
  }

  MotorComponent copyWith({
    String? id,
    String? manufacturer,
    String? model,
    double? kvRating,
    double? minimumVoltageV,
    double? maximumVoltageV,
    double? continuousPowerW,
    double? maximumPowerW,
    double? continuousCurrentA,
    double? maximumCurrentA,
    double? efficiency,
    double? weightG,
    double? minimumRecommendedPropellerDiameterInch,
    double? maximumRecommendedPropellerDiameterInch,
    int? minimumRecommendedCellCount,
    int? maximumRecommendedCellCount,
    String? notes,
  }) {
    return MotorComponent(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      kvRating: kvRating ?? this.kvRating,
      minimumVoltageV: minimumVoltageV ?? this.minimumVoltageV,
      maximumVoltageV: maximumVoltageV ?? this.maximumVoltageV,
      continuousPowerW: continuousPowerW ?? this.continuousPowerW,
      maximumPowerW: maximumPowerW ?? this.maximumPowerW,
      continuousCurrentA: continuousCurrentA ?? this.continuousCurrentA,
      maximumCurrentA: maximumCurrentA ?? this.maximumCurrentA,
      efficiency: efficiency ?? this.efficiency,
      weightG: weightG ?? this.weightG,
      minimumRecommendedPropellerDiameterInch:
          minimumRecommendedPropellerDiameterInch ??
          this.minimumRecommendedPropellerDiameterInch,
      maximumRecommendedPropellerDiameterInch:
          maximumRecommendedPropellerDiameterInch ??
          this.maximumRecommendedPropellerDiameterInch,
      minimumRecommendedCellCount:
          minimumRecommendedCellCount ?? this.minimumRecommendedCellCount,
      maximumRecommendedCellCount:
          maximumRecommendedCellCount ?? this.maximumRecommendedCellCount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'kvRating': kvRating,
      'minimumVoltageV': minimumVoltageV,
      'maximumVoltageV': maximumVoltageV,
      'continuousPowerW': continuousPowerW,
      'maximumPowerW': maximumPowerW,
      'continuousCurrentA': continuousCurrentA,
      'maximumCurrentA': maximumCurrentA,
      'efficiency': efficiency,
      'weightG': weightG,
      'minimumRecommendedPropellerDiameterInch':
          minimumRecommendedPropellerDiameterInch,
      'maximumRecommendedPropellerDiameterInch':
          maximumRecommendedPropellerDiameterInch,
      'minimumRecommendedCellCount': minimumRecommendedCellCount,
      'maximumRecommendedCellCount': maximumRecommendedCellCount,
      'notes': notes,
    };
  }

  factory MotorComponent.fromMap(Map<String, Object?> map) {
    return MotorComponent(
      id: map['id']! as String,
      manufacturer: map['manufacturer']! as String,
      model: map['model']! as String,
      kvRating: (map['kvRating']! as num).toDouble(),
      minimumVoltageV: (map['minimumVoltageV']! as num).toDouble(),
      maximumVoltageV: (map['maximumVoltageV']! as num).toDouble(),
      continuousPowerW: (map['continuousPowerW']! as num).toDouble(),
      maximumPowerW: (map['maximumPowerW']! as num).toDouble(),
      continuousCurrentA: (map['continuousCurrentA']! as num).toDouble(),
      maximumCurrentA: (map['maximumCurrentA']! as num).toDouble(),
      efficiency: (map['efficiency']! as num).toDouble(),
      weightG: (map['weightG']! as num).toDouble(),
      minimumRecommendedPropellerDiameterInch:
          (map['minimumRecommendedPropellerDiameterInch']! as num).toDouble(),
      maximumRecommendedPropellerDiameterInch:
          (map['maximumRecommendedPropellerDiameterInch']! as num).toDouble(),
      minimumRecommendedCellCount: map['minimumRecommendedCellCount']! as int,
      maximumRecommendedCellCount: map['maximumRecommendedCellCount']! as int,
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
