class AircraftMassStation {
  final String name;
  final double massKg;
  final double armFromDatumM;

  const AircraftMassStation({
    required this.name,
    required this.massKg,
    required this.armFromDatumM,
  });

  bool get isValid {
    return name.trim().isNotEmpty &&
        massKg.isFinite &&
        armFromDatumM.isFinite &&
        massKg > 0.0;
  }

  AircraftMassStation copyWith({
    String? name,
    double? massKg,
    double? armFromDatumM,
  }) {
    return AircraftMassStation(
      name: name ?? this.name,
      massKg: massKg ?? this.massKg,
      armFromDatumM: armFromDatumM ?? this.armFromDatumM,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'massKg': massKg, 'armFromDatumM': armFromDatumM};
  }

  factory AircraftMassStation.fromMap(Map<String, dynamic> map) {
    return AircraftMassStation(
      name: map['name']?.toString() ?? '',
      massKg: _toDouble(map['massKg']),
      armFromDatumM: _toDouble(map['armFromDatumM']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0.0;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AircraftMassStation &&
            other.name == name &&
            other.massKg == massKg &&
            other.armFromDatumM == armFromDatumM;
  }

  @override
  int get hashCode => Object.hash(name, massKg, armFromDatumM);

  @override
  String toString() {
    return 'AircraftMassStation('
        'name: $name, '
        'massKg: $massKg, '
        'armFromDatumM: $armFromDatumM'
        ')';
  }
}
