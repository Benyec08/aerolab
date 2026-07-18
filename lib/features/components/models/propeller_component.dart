class PropellerComponent {
  final String id;
  final String manufacturer;
  final String model;
  final double diameterInch;
  final double pitchInch;
  final int bladeCount;
  final String material;
  final double weightG;
  final double minimumRecommendedKv;
  final double maximumRecommendedKv;
  final double minimumRecommendedVoltageV;
  final double maximumRecommendedVoltageV;
  final String rotationDirection;
  final String notes;

  PropellerComponent({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.diameterInch,
    required this.pitchInch,
    required this.bladeCount,
    required this.material,
    required this.weightG,
    required this.minimumRecommendedKv,
    required this.maximumRecommendedKv,
    required this.minimumRecommendedVoltageV,
    required this.maximumRecommendedVoltageV,
    this.rotationDirection = 'CW/CCW',
    this.notes = '',
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Pervane kimliği boş olamaz.');
    }

    if (manufacturer.trim().isEmpty) {
      throw ArgumentError.value(
        manufacturer,
        'manufacturer',
        'Üretici adı boş olamaz.',
      );
    }

    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'Pervane modeli boş olamaz.');
    }

    if (diameterInch <= 0) {
      throw ArgumentError.value(
        diameterInch,
        'diameterInch',
        'Pervane çapı sıfırdan büyük olmalıdır.',
      );
    }

    if (pitchInch <= 0) {
      throw ArgumentError.value(
        pitchInch,
        'pitchInch',
        'Pervane pitch değeri sıfırdan büyük olmalıdır.',
      );
    }

    if (bladeCount < 2) {
      throw ArgumentError.value(
        bladeCount,
        'bladeCount',
        'Pervane en az iki kanatlı olmalıdır.',
      );
    }

    if (material.trim().isEmpty) {
      throw ArgumentError.value(
        material,
        'material',
        'Pervane malzemesi boş olamaz.',
      );
    }

    if (weightG <= 0) {
      throw ArgumentError.value(
        weightG,
        'weightG',
        'Pervane ağırlığı sıfırdan büyük olmalıdır.',
      );
    }

    if (minimumRecommendedKv <= 0 || maximumRecommendedKv <= 0) {
      throw ArgumentError('Önerilen KV değerleri sıfırdan büyük olmalıdır.');
    }

    if (minimumRecommendedKv > maximumRecommendedKv) {
      throw ArgumentError(
        'Minimum önerilen KV maksimum değerden büyük olamaz.',
      );
    }

    if (minimumRecommendedVoltageV <= 0 || maximumRecommendedVoltageV <= 0) {
      throw ArgumentError(
        'Önerilen voltaj değerleri sıfırdan büyük olmalıdır.',
      );
    }

    if (minimumRecommendedVoltageV > maximumRecommendedVoltageV) {
      throw ArgumentError(
        'Minimum önerilen voltaj maksimum değerden büyük olamaz.',
      );
    }

    final normalizedDirection = rotationDirection.trim().toUpperCase();

    if (normalizedDirection != 'CW' &&
        normalizedDirection != 'CCW' &&
        normalizedDirection != 'CW/CCW') {
      throw ArgumentError.value(
        rotationDirection,
        'rotationDirection',
        'Dönüş yönü CW, CCW veya CW/CCW olmalıdır.',
      );
    }
  }

  String get displayName =>
      '$manufacturer $model '
      '${diameterInch.toStringAsFixed(1)}x${pitchInch.toStringAsFixed(1)}';

  double get diskAreaM2 {
    final diameterM = diameterInch * 0.0254;
    final radiusM = diameterM / 2.0;
    return 3.141592653589793 * radiusM * radiusM;
  }

  bool supportsMotorKv(double kvRating) {
    return kvRating >= minimumRecommendedKv && kvRating <= maximumRecommendedKv;
  }

  bool supportsVoltage(double voltageV) {
    return voltageV >= minimumRecommendedVoltageV &&
        voltageV <= maximumRecommendedVoltageV;
  }

  PropellerComponent copyWith({
    String? id,
    String? manufacturer,
    String? model,
    double? diameterInch,
    double? pitchInch,
    int? bladeCount,
    String? material,
    double? weightG,
    double? minimumRecommendedKv,
    double? maximumRecommendedKv,
    double? minimumRecommendedVoltageV,
    double? maximumRecommendedVoltageV,
    String? rotationDirection,
    String? notes,
  }) {
    return PropellerComponent(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      diameterInch: diameterInch ?? this.diameterInch,
      pitchInch: pitchInch ?? this.pitchInch,
      bladeCount: bladeCount ?? this.bladeCount,
      material: material ?? this.material,
      weightG: weightG ?? this.weightG,
      minimumRecommendedKv: minimumRecommendedKv ?? this.minimumRecommendedKv,
      maximumRecommendedKv: maximumRecommendedKv ?? this.maximumRecommendedKv,
      minimumRecommendedVoltageV:
          minimumRecommendedVoltageV ?? this.minimumRecommendedVoltageV,
      maximumRecommendedVoltageV:
          maximumRecommendedVoltageV ?? this.maximumRecommendedVoltageV,
      rotationDirection: rotationDirection ?? this.rotationDirection,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'diameterInch': diameterInch,
      'pitchInch': pitchInch,
      'bladeCount': bladeCount,
      'material': material,
      'weightG': weightG,
      'minimumRecommendedKv': minimumRecommendedKv,
      'maximumRecommendedKv': maximumRecommendedKv,
      'minimumRecommendedVoltageV': minimumRecommendedVoltageV,
      'maximumRecommendedVoltageV': maximumRecommendedVoltageV,
      'rotationDirection': rotationDirection,
      'notes': notes,
    };
  }

  factory PropellerComponent.fromMap(Map<String, Object?> map) {
    return PropellerComponent(
      id: map['id']! as String,
      manufacturer: map['manufacturer']! as String,
      model: map['model']! as String,
      diameterInch: (map['diameterInch']! as num).toDouble(),
      pitchInch: (map['pitchInch']! as num).toDouble(),
      bladeCount: map['bladeCount']! as int,
      material: map['material']! as String,
      weightG: (map['weightG']! as num).toDouble(),
      minimumRecommendedKv: (map['minimumRecommendedKv']! as num).toDouble(),
      maximumRecommendedKv: (map['maximumRecommendedKv']! as num).toDouble(),
      minimumRecommendedVoltageV: (map['minimumRecommendedVoltageV']! as num)
          .toDouble(),
      maximumRecommendedVoltageV: (map['maximumRecommendedVoltageV']! as num)
          .toDouble(),
      rotationDirection: (map['rotationDirection'] as String?) ?? 'CW/CCW',
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
