class EscComponent {
  final String id;
  final String manufacturer;
  final String model;
  final double continuousCurrentA;
  final double burstCurrentA;
  final int minimumSupportedCellCount;
  final int maximumSupportedCellCount;
  final double efficiency;
  final double weightG;
  final bool hasBec;
  final double becVoltageV;
  final double becCurrentA;
  final String notes;

  EscComponent({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.continuousCurrentA,
    required this.burstCurrentA,
    required this.minimumSupportedCellCount,
    required this.maximumSupportedCellCount,
    required this.efficiency,
    required this.weightG,
    required this.hasBec,
    this.becVoltageV = 0.0,
    this.becCurrentA = 0.0,
    this.notes = '',
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'ESC kimliği boş olamaz.');
    }

    if (manufacturer.trim().isEmpty) {
      throw ArgumentError.value(
        manufacturer,
        'manufacturer',
        'Üretici adı boş olamaz.',
      );
    }

    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'ESC modeli boş olamaz.');
    }

    if (continuousCurrentA <= 0) {
      throw ArgumentError.value(
        continuousCurrentA,
        'continuousCurrentA',
        'Sürekli ESC akımı sıfırdan büyük olmalıdır.',
      );
    }

    if (burstCurrentA <= 0) {
      throw ArgumentError.value(
        burstCurrentA,
        'burstCurrentA',
        'Burst ESC akımı sıfırdan büyük olmalıdır.',
      );
    }

    if (continuousCurrentA > burstCurrentA) {
      throw ArgumentError('Sürekli ESC akımı burst akımından büyük olamaz.');
    }

    if (minimumSupportedCellCount <= 0 || maximumSupportedCellCount <= 0) {
      throw ArgumentError(
        'Desteklenen hücre sayıları sıfırdan büyük olmalıdır.',
      );
    }

    if (minimumSupportedCellCount > maximumSupportedCellCount) {
      throw ArgumentError(
        'Minimum hücre sayısı maksimum hücre sayısından büyük olamaz.',
      );
    }

    if (efficiency <= 0 || efficiency > 1) {
      throw ArgumentError.value(
        efficiency,
        'efficiency',
        'ESC verimi 0 ile 1 arasında olmalıdır.',
      );
    }

    if (weightG <= 0) {
      throw ArgumentError.value(
        weightG,
        'weightG',
        'ESC ağırlığı sıfırdan büyük olmalıdır.',
      );
    }

    if (hasBec) {
      if (becVoltageV <= 0) {
        throw ArgumentError.value(
          becVoltageV,
          'becVoltageV',
          'BEC voltajı sıfırdan büyük olmalıdır.',
        );
      }

      if (becCurrentA <= 0) {
        throw ArgumentError.value(
          becCurrentA,
          'becCurrentA',
          'BEC akımı sıfırdan büyük olmalıdır.',
        );
      }
    } else {
      if (becVoltageV != 0 || becCurrentA != 0) {
        throw ArgumentError(
          'BEC bulunmayan ESC için BEC voltajı ve akımı sıfır olmalıdır.',
        );
      }
    }
  }

  String get displayName => '$manufacturer $model';

  bool supportsCellCount(int cellCount) {
    return cellCount >= minimumSupportedCellCount &&
        cellCount <= maximumSupportedCellCount;
  }

  bool supportsContinuousCurrent(double currentA) {
    return currentA <= continuousCurrentA;
  }

  bool supportsBurstCurrent(double currentA) {
    return currentA <= burstCurrentA;
  }

  double continuousCurrentReserveA(double requiredCurrentA) {
    return continuousCurrentA - requiredCurrentA;
  }

  double burstCurrentReserveA(double requiredCurrentA) {
    return burstCurrentA - requiredCurrentA;
  }

  EscComponent copyWith({
    String? id,
    String? manufacturer,
    String? model,
    double? continuousCurrentA,
    double? burstCurrentA,
    int? minimumSupportedCellCount,
    int? maximumSupportedCellCount,
    double? efficiency,
    double? weightG,
    bool? hasBec,
    double? becVoltageV,
    double? becCurrentA,
    String? notes,
  }) {
    return EscComponent(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      continuousCurrentA: continuousCurrentA ?? this.continuousCurrentA,
      burstCurrentA: burstCurrentA ?? this.burstCurrentA,
      minimumSupportedCellCount:
          minimumSupportedCellCount ?? this.minimumSupportedCellCount,
      maximumSupportedCellCount:
          maximumSupportedCellCount ?? this.maximumSupportedCellCount,
      efficiency: efficiency ?? this.efficiency,
      weightG: weightG ?? this.weightG,
      hasBec: hasBec ?? this.hasBec,
      becVoltageV: becVoltageV ?? this.becVoltageV,
      becCurrentA: becCurrentA ?? this.becCurrentA,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'continuousCurrentA': continuousCurrentA,
      'burstCurrentA': burstCurrentA,
      'minimumSupportedCellCount': minimumSupportedCellCount,
      'maximumSupportedCellCount': maximumSupportedCellCount,
      'efficiency': efficiency,
      'weightG': weightG,
      'hasBec': hasBec,
      'becVoltageV': becVoltageV,
      'becCurrentA': becCurrentA,
      'notes': notes,
    };
  }

  factory EscComponent.fromMap(Map<String, Object?> map) {
    return EscComponent(
      id: map['id']! as String,
      manufacturer: map['manufacturer']! as String,
      model: map['model']! as String,
      continuousCurrentA: (map['continuousCurrentA']! as num).toDouble(),
      burstCurrentA: (map['burstCurrentA']! as num).toDouble(),
      minimumSupportedCellCount: map['minimumSupportedCellCount']! as int,
      maximumSupportedCellCount: map['maximumSupportedCellCount']! as int,
      efficiency: (map['efficiency']! as num).toDouble(),
      weightG: (map['weightG']! as num).toDouble(),
      hasBec: map['hasBec']! as bool,
      becVoltageV: (map['becVoltageV']! as num).toDouble(),
      becCurrentA: (map['becCurrentA']! as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
