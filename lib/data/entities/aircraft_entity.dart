import 'package:hive_ce/hive_ce.dart';

part 'aircraft_entity.g.dart';

@HiveType(typeId: 0)
class AircraftEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double weightKg;

  @HiveField(4)
  final double wingAreaM2;

  @HiveField(5)
  final double wingSpanM;

  @HiveField(6)
  final int motorCount;

  @HiveField(7)
  final double motorPowerW;

  @HiveField(8)
  final double propellerDiameterInch;

  @HiveField(9)
  final double batteryCapacityMah;

  @HiveField(10)
  final double batteryVoltageV;

  @HiveField(11)
  final String batteryType;

  @HiveField(12)
  final int batteryCellCount;

  @HiveField(13)
  final String batteryDescription;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  // Sprint 10B
  // Sabit kanat ve kanatlı VTOL araçları için aerodinamik girdiler.
  //
  // Varsayılan değerler, Sprint 10B öncesinde kaydedilmiş Hive
  // kayıtlarının güvenli biçimde okunabilmesini sağlar.
  @HiveField(16, defaultValue: 15.0)
  final double cruiseSpeedMs;

  @HiveField(17, defaultValue: 0.030)
  final double zeroLiftDragCoefficient;

  @HiveField(18, defaultValue: 1.4)
  final double maxLiftCoefficient;

  @HiveField(19, defaultValue: 0.80)
  final double oswaldEfficiencyFactor;

  // Sprint 11A
  //
  // Verim değerleri yüzde yerine 0–1 aralığında saklanır.
  @HiveField(20, defaultValue: 0.95)
  final double escEfficiency;

  @HiveField(21, defaultValue: 0.85)
  final double motorEfficiency;

  /// Motor sisteminin güvenli biçimde sağlayabildiği toplam sürekli güç.
  ///
  /// Eski Hive kayıtlarında bu alan bulunmadığı için 0.0 okunabilir.
  /// Constructor içindeki fallback sayesinde motorPowerW kullanılır.
  @HiveField(22, defaultValue: 0.0)
  final double continuousMotorPowerW;

  /// Motor sisteminin kısa süreli sağlayabildiği toplam maksimum güç.
  ///
  /// Eski Hive kayıtlarında bu alan bulunmadığı için 0.0 okunabilir.
  /// Constructor içindeki fallback sayesinde motorPowerW kullanılır.
  @HiveField(23, defaultValue: 0.0)
  final double maximumMotorPowerW;

  // Sprint 12A
  //
  // Hücre başına iç direnç mΩ cinsindedir.
  //
  // 0.0 değeri, kayıt içinde özel bir değer bulunmadığını belirtir.
  // Bu durumda BatteryChemistryService kimyaya bağlı varsayılanı kullanır.
  @HiveField(24, defaultValue: 0.0)
  final double cellInternalResistanceMilliOhm;

  // Sprint 14D
  //
  // Komponent veritabanından seçilen kayıtların kimlikleri.
  //
  // Nullable alanlar sayesinde eski Hive kayıtları ve manuel giriş akışı
  // geriye dönük olarak korunur.
  @HiveField(25)
  final String? motorComponentId;

  @HiveField(26)
  final String? propellerComponentId;

  @HiveField(27)
  final String? batteryComponentId;

  @HiveField(28)
  final String? escComponentId;

  @HiveField(29)
  final String? motorPropellerCombinationId;

  AircraftEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.weightKg,
    required this.wingAreaM2,
    required this.wingSpanM,
    required this.motorCount,
    required this.motorPowerW,
    required this.propellerDiameterInch,
    required this.batteryCapacityMah,
    required this.batteryVoltageV,
    required this.batteryType,
    required this.batteryCellCount,
    required this.batteryDescription,
    required this.createdAt,
    required this.updatedAt,
    this.cruiseSpeedMs = 15.0,
    this.zeroLiftDragCoefficient = 0.030,
    this.maxLiftCoefficient = 1.4,
    this.oswaldEfficiencyFactor = 0.80,
    this.escEfficiency = 0.95,
    this.motorEfficiency = 0.85,
    double? continuousMotorPowerW,
    double? maximumMotorPowerW,
    double? cellInternalResistanceMilliOhm,
    this.motorComponentId,
    this.propellerComponentId,
    this.batteryComponentId,
    this.escComponentId,
    this.motorPropellerCombinationId,
  }) : continuousMotorPowerW =
           continuousMotorPowerW == null || continuousMotorPowerW <= 0
           ? motorPowerW
           : continuousMotorPowerW,
       maximumMotorPowerW =
           maximumMotorPowerW == null || maximumMotorPowerW <= 0
           ? motorPowerW
           : maximumMotorPowerW,
       cellInternalResistanceMilliOhm =
           cellInternalResistanceMilliOhm == null ||
               cellInternalResistanceMilliOhm <= 0
           ? 0.0
           : cellInternalResistanceMilliOhm;

  factory AircraftEntity.create({
    required String name,
    required String type,
    required double weightKg,
    required double wingAreaM2,
    required double wingSpanM,
    required int motorCount,
    required double motorPowerW,
    required double propellerDiameterInch,
    required double batteryCapacityMah,
    required double batteryVoltageV,
    required String batteryType,
    required int batteryCellCount,
    String batteryDescription = '',
    double cruiseSpeedMs = 15.0,
    double zeroLiftDragCoefficient = 0.030,
    double maxLiftCoefficient = 1.4,
    double oswaldEfficiencyFactor = 0.80,
    double escEfficiency = 0.95,
    double motorEfficiency = 0.85,
    double? continuousMotorPowerW,
    double? maximumMotorPowerW,
    double? cellInternalResistanceMilliOhm,
    String? motorComponentId,
    String? propellerComponentId,
    String? batteryComponentId,
    String? escComponentId,
    String? motorPropellerCombinationId,
  }) {
    final now = DateTime.now();

    return AircraftEntity(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      type: type,
      weightKg: weightKg,
      wingAreaM2: wingAreaM2,
      wingSpanM: wingSpanM,
      motorCount: motorCount,
      motorPowerW: motorPowerW,
      propellerDiameterInch: propellerDiameterInch,
      batteryCapacityMah: batteryCapacityMah,
      batteryVoltageV: batteryVoltageV,
      batteryType: batteryType,
      batteryCellCount: batteryCellCount,
      batteryDescription: batteryDescription,
      createdAt: now,
      updatedAt: now,
      cruiseSpeedMs: cruiseSpeedMs,
      zeroLiftDragCoefficient: zeroLiftDragCoefficient,
      maxLiftCoefficient: maxLiftCoefficient,
      oswaldEfficiencyFactor: oswaldEfficiencyFactor,
      escEfficiency: escEfficiency,
      motorEfficiency: motorEfficiency,
      continuousMotorPowerW: continuousMotorPowerW,
      maximumMotorPowerW: maximumMotorPowerW,
      cellInternalResistanceMilliOhm: cellInternalResistanceMilliOhm,
      motorComponentId: motorComponentId,
      propellerComponentId: propellerComponentId,
      batteryComponentId: batteryComponentId,
      escComponentId: escComponentId,
      motorPropellerCombinationId: motorPropellerCombinationId,
    );
  }

  AircraftEntity copyWith({
    String? id,
    String? name,
    String? type,
    double? weightKg,
    double? wingAreaM2,
    double? wingSpanM,
    int? motorCount,
    double? motorPowerW,
    double? propellerDiameterInch,
    double? batteryCapacityMah,
    double? batteryVoltageV,
    String? batteryType,
    int? batteryCellCount,
    String? batteryDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? cruiseSpeedMs,
    double? zeroLiftDragCoefficient,
    double? maxLiftCoefficient,
    double? oswaldEfficiencyFactor,
    double? escEfficiency,
    double? motorEfficiency,
    double? continuousMotorPowerW,
    double? maximumMotorPowerW,
    double? cellInternalResistanceMilliOhm,
    String? motorComponentId,
    String? propellerComponentId,
    String? batteryComponentId,
    String? escComponentId,
    String? motorPropellerCombinationId,
  }) {
    final updatedMotorPowerW = motorPowerW ?? this.motorPowerW;

    return AircraftEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      weightKg: weightKg ?? this.weightKg,
      wingAreaM2: wingAreaM2 ?? this.wingAreaM2,
      wingSpanM: wingSpanM ?? this.wingSpanM,
      motorCount: motorCount ?? this.motorCount,
      motorPowerW: updatedMotorPowerW,
      propellerDiameterInch:
          propellerDiameterInch ?? this.propellerDiameterInch,
      batteryCapacityMah: batteryCapacityMah ?? this.batteryCapacityMah,
      batteryVoltageV: batteryVoltageV ?? this.batteryVoltageV,
      batteryType: batteryType ?? this.batteryType,
      batteryCellCount: batteryCellCount ?? this.batteryCellCount,
      batteryDescription: batteryDescription ?? this.batteryDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      cruiseSpeedMs: cruiseSpeedMs ?? this.cruiseSpeedMs,
      zeroLiftDragCoefficient:
          zeroLiftDragCoefficient ?? this.zeroLiftDragCoefficient,
      maxLiftCoefficient: maxLiftCoefficient ?? this.maxLiftCoefficient,
      oswaldEfficiencyFactor:
          oswaldEfficiencyFactor ?? this.oswaldEfficiencyFactor,
      escEfficiency: escEfficiency ?? this.escEfficiency,
      motorEfficiency: motorEfficiency ?? this.motorEfficiency,
      continuousMotorPowerW:
          continuousMotorPowerW ?? this.continuousMotorPowerW,
      maximumMotorPowerW: maximumMotorPowerW ?? this.maximumMotorPowerW,
      cellInternalResistanceMilliOhm:
          cellInternalResistanceMilliOhm ?? this.cellInternalResistanceMilliOhm,
      motorComponentId: motorComponentId ?? this.motorComponentId,
      propellerComponentId: propellerComponentId ?? this.propellerComponentId,
      batteryComponentId: batteryComponentId ?? this.batteryComponentId,
      escComponentId: escComponentId ?? this.escComponentId,
      motorPropellerCombinationId:
          motorPropellerCombinationId ?? this.motorPropellerCombinationId,
    );
  }

  factory AircraftEntity.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final motorPowerW = _toDouble(map['motorPower']);

    return AircraftEntity(
      id: map['id']?.toString() ?? now.microsecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Sabit Kanat',
      weightKg: _toDouble(map['weight']),
      wingAreaM2: _toDouble(map['wingArea']),
      wingSpanM: _toDouble(map['wingSpan']),
      motorCount: _toInt(map['motorCount'], fallback: 1),
      motorPowerW: motorPowerW,
      propellerDiameterInch: _toDouble(map['propellerDiameter']),
      batteryCapacityMah: _toDouble(map['batteryCapacity']),
      batteryVoltageV: _toDouble(map['batteryVoltage']),
      batteryType: map['batteryType']?.toString() ?? 'LiPo',
      batteryCellCount: _toInt(map['batteryCellCount'], fallback: 1),
      batteryDescription: map['battery']?.toString() ?? '',
      createdAt: _toDateTime(map['created'], fallback: now),
      updatedAt: _toDateTime(map['updated'], fallback: now),
      cruiseSpeedMs: _toDouble(map['cruiseSpeedMs'], fallback: 15.0),
      zeroLiftDragCoefficient: _toDouble(
        map['zeroLiftDragCoefficient'],
        fallback: 0.030,
      ),
      maxLiftCoefficient: _toDouble(map['maxLiftCoefficient'], fallback: 1.4),
      oswaldEfficiencyFactor: _toDouble(
        map['oswaldEfficiencyFactor'],
        fallback: 0.80,
      ),
      escEfficiency: _toDouble(map['escEfficiency'], fallback: 0.95),
      motorEfficiency: _toDouble(map['motorEfficiency'], fallback: 0.85),
      continuousMotorPowerW: _toDouble(
        map['continuousMotorPowerW'],
        fallback: motorPowerW,
      ),
      maximumMotorPowerW: _toDouble(
        map['maximumMotorPowerW'],
        fallback: motorPowerW,
      ),
      cellInternalResistanceMilliOhm: _toDouble(
        map['cellInternalResistanceMilliOhm'],
        fallback: 0.0,
      ),
      motorComponentId: _toNullableString(map['motorComponentId']),
      propellerComponentId: _toNullableString(map['propellerComponentId']),
      batteryComponentId: _toNullableString(map['batteryComponentId']),
      escComponentId: _toNullableString(map['escComponentId']),
      motorPropellerCombinationId: _toNullableString(
        map['motorPropellerCombinationId'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'weight': weightKg,
      'wingArea': wingAreaM2,
      'wingSpan': wingSpanM,
      'motorCount': motorCount,
      'motorPower': motorPowerW,
      'propellerDiameter': propellerDiameterInch,
      'batteryCapacity': batteryCapacityMah,
      'batteryVoltage': batteryVoltageV,
      'batteryType': batteryType,
      'batteryCellCount': batteryCellCount,
      'battery': batteryDescription.isEmpty
          ? '${batteryCellCount}S $batteryType'
          : batteryDescription,
      'created': createdAt,
      'updated': updatedAt,
      'cruiseSpeedMs': cruiseSpeedMs,
      'zeroLiftDragCoefficient': zeroLiftDragCoefficient,
      'maxLiftCoefficient': maxLiftCoefficient,
      'oswaldEfficiencyFactor': oswaldEfficiencyFactor,
      'escEfficiency': escEfficiency,
      'motorEfficiency': motorEfficiency,
      'continuousMotorPowerW': continuousMotorPowerW,
      'maximumMotorPowerW': maximumMotorPowerW,
      'cellInternalResistanceMilliOhm': cellInternalResistanceMilliOhm,
      'motorComponentId': motorComponentId,
      'propellerComponentId': propellerComponentId,
      'batteryComponentId': batteryComponentId,
      'escComponentId': escComponentId,
      'motorPropellerCombinationId': motorPropellerCombinationId,
    };
  }

  static String? _toNullableString(dynamic value) {
    final normalizedValue = value?.toString().trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ??
        fallback;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime _toDateTime(dynamic value, {required DateTime fallback}) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AircraftEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
