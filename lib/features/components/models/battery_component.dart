class BatteryComponent {
  final String id;
  final String manufacturer;
  final String model;
  final String chemistry;
  final int cellCount;
  final double capacityMah;
  final double nominalVoltageV;
  final double continuousCRate;
  final double burstCRate;
  final double cellInternalResistanceMilliOhm;
  final double weightG;
  final String notes;

  BatteryComponent({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.chemistry,
    required this.cellCount,
    required this.capacityMah,
    required this.nominalVoltageV,
    required this.continuousCRate,
    required this.burstCRate,
    required this.cellInternalResistanceMilliOhm,
    required this.weightG,
    this.notes = '',
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Batarya kimliği boş olamaz.');
    }

    if (manufacturer.trim().isEmpty) {
      throw ArgumentError.value(
        manufacturer,
        'manufacturer',
        'Üretici adı boş olamaz.',
      );
    }

    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'Batarya modeli boş olamaz.');
    }

    final normalizedChemistry = chemistry.trim().toUpperCase();

    if (normalizedChemistry != 'LIPO' &&
        normalizedChemistry != 'LI-ION' &&
        normalizedChemistry != 'LIION' &&
        normalizedChemistry != 'LIHV') {
      throw ArgumentError.value(
        chemistry,
        'chemistry',
        'Batarya kimyası LiPo, Li-Ion veya LiHV olmalıdır.',
      );
    }

    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    if (capacityMah <= 0) {
      throw ArgumentError.value(
        capacityMah,
        'capacityMah',
        'Batarya kapasitesi sıfırdan büyük olmalıdır.',
      );
    }

    if (nominalVoltageV <= 0) {
      throw ArgumentError.value(
        nominalVoltageV,
        'nominalVoltageV',
        'Nominal voltaj sıfırdan büyük olmalıdır.',
      );
    }

    if (continuousCRate <= 0) {
      throw ArgumentError.value(
        continuousCRate,
        'continuousCRate',
        'Sürekli C-rate sıfırdan büyük olmalıdır.',
      );
    }

    if (burstCRate <= 0) {
      throw ArgumentError.value(
        burstCRate,
        'burstCRate',
        'Burst C-rate sıfırdan büyük olmalıdır.',
      );
    }

    if (continuousCRate > burstCRate) {
      throw ArgumentError(
        'Sürekli C-rate burst C-rate değerinden büyük olamaz.',
      );
    }

    if (cellInternalResistanceMilliOhm <= 0) {
      throw ArgumentError.value(
        cellInternalResistanceMilliOhm,
        'cellInternalResistanceMilliOhm',
        'Hücre iç direnci sıfırdan büyük olmalıdır.',
      );
    }

    if (weightG <= 0) {
      throw ArgumentError.value(
        weightG,
        'weightG',
        'Batarya ağırlığı sıfırdan büyük olmalıdır.',
      );
    }
  }

  String get displayName => '$manufacturer $model';

  double get capacityAh => capacityMah / 1000.0;

  double get nominalEnergyWh => nominalVoltageV * capacityAh;

  double get maximumContinuousCurrentA => capacityAh * continuousCRate;

  double get maximumBurstCurrentA => capacityAh * burstCRate;

  double get packInternalResistanceOhm =>
      (cellInternalResistanceMilliOhm * cellCount) / 1000.0;

  double get nominalCellVoltageV => nominalVoltageV / cellCount;

  bool supportsContinuousCurrent(double currentA) {
    return currentA <= maximumContinuousCurrentA;
  }

  bool supportsBurstCurrent(double currentA) {
    return currentA <= maximumBurstCurrentA;
  }

  bool supportsRequiredPower({
    required double requiredPowerW,
    required double loadedVoltageV,
  }) {
    if (requiredPowerW < 0) {
      throw ArgumentError.value(
        requiredPowerW,
        'requiredPowerW',
        'Gerekli güç negatif olamaz.',
      );
    }

    if (loadedVoltageV <= 0) {
      throw ArgumentError.value(
        loadedVoltageV,
        'loadedVoltageV',
        'Yüklü voltaj sıfırdan büyük olmalıdır.',
      );
    }

    final requiredCurrentA = requiredPowerW / loadedVoltageV;
    return supportsContinuousCurrent(requiredCurrentA);
  }

  BatteryComponent copyWith({
    String? id,
    String? manufacturer,
    String? model,
    String? chemistry,
    int? cellCount,
    double? capacityMah,
    double? nominalVoltageV,
    double? continuousCRate,
    double? burstCRate,
    double? cellInternalResistanceMilliOhm,
    double? weightG,
    String? notes,
  }) {
    return BatteryComponent(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      chemistry: chemistry ?? this.chemistry,
      cellCount: cellCount ?? this.cellCount,
      capacityMah: capacityMah ?? this.capacityMah,
      nominalVoltageV: nominalVoltageV ?? this.nominalVoltageV,
      continuousCRate: continuousCRate ?? this.continuousCRate,
      burstCRate: burstCRate ?? this.burstCRate,
      cellInternalResistanceMilliOhm:
          cellInternalResistanceMilliOhm ?? this.cellInternalResistanceMilliOhm,
      weightG: weightG ?? this.weightG,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'chemistry': chemistry,
      'cellCount': cellCount,
      'capacityMah': capacityMah,
      'nominalVoltageV': nominalVoltageV,
      'continuousCRate': continuousCRate,
      'burstCRate': burstCRate,
      'cellInternalResistanceMilliOhm': cellInternalResistanceMilliOhm,
      'weightG': weightG,
      'notes': notes,
    };
  }

  factory BatteryComponent.fromMap(Map<String, Object?> map) {
    return BatteryComponent(
      id: map['id']! as String,
      manufacturer: map['manufacturer']! as String,
      model: map['model']! as String,
      chemistry: map['chemistry']! as String,
      cellCount: map['cellCount']! as int,
      capacityMah: (map['capacityMah']! as num).toDouble(),
      nominalVoltageV: (map['nominalVoltageV']! as num).toDouble(),
      continuousCRate: (map['continuousCRate']! as num).toDouble(),
      burstCRate: (map['burstCRate']! as num).toDouble(),
      cellInternalResistanceMilliOhm:
          (map['cellInternalResistanceMilliOhm']! as num).toDouble(),
      weightG: (map['weightG']! as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
