import '../models/motor_component.dart';
import 'component_repository.dart';

class MotorRepository implements ComponentRepository<MotorComponent> {
  final List<MotorComponent> _motors;

  MotorRepository({List<MotorComponent> initialMotors = const []})
    : _motors = List<MotorComponent>.unmodifiable(initialMotors);

  @override
  List<MotorComponent> getAll() {
    return List<MotorComponent>.unmodifiable(_motors);
  }

  @override
  MotorComponent? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final motor in _motors) {
      if (motor.id == normalizedId) {
        return motor;
      }
    }

    return null;
  }

  @override
  List<MotorComponent> searchByModel(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where((motor) {
        final searchableText = [
          motor.manufacturer,
          motor.model,
          motor.displayName,
          motor.kvRating.toStringAsFixed(0),
        ].join(' ').toLowerCase();

        return searchableText.contains(normalizedQuery);
      }),
    );
  }

  @override
  List<MotorComponent> filterByManufacturer(String manufacturer) {
    final normalizedManufacturer = manufacturer.trim().toLowerCase();

    if (normalizedManufacturer.isEmpty) {
      return getAll();
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where(
        (motor) =>
            motor.manufacturer.trim().toLowerCase() == normalizedManufacturer,
      ),
    );
  }

  List<MotorComponent> filterByKvRange({
    required double minimumKv,
    required double maximumKv,
  }) {
    if (minimumKv <= 0 || maximumKv <= 0) {
      throw ArgumentError('KV filtre değerleri sıfırdan büyük olmalıdır.');
    }

    if (minimumKv > maximumKv) {
      throw ArgumentError('Minimum KV maksimum KV değerinden büyük olamaz.');
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where(
        (motor) => motor.kvRating >= minimumKv && motor.kvRating <= maximumKv,
      ),
    );
  }

  List<MotorComponent> filterByVoltage(double voltageV) {
    if (voltageV <= 0) {
      throw ArgumentError.value(
        voltageV,
        'voltageV',
        'Voltaj sıfırdan büyük olmalıdır.',
      );
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where((motor) => motor.supportsVoltage(voltageV)),
    );
  }

  List<MotorComponent> filterByCellCount(int cellCount) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where((motor) => motor.supportsCellCount(cellCount)),
    );
  }

  List<MotorComponent> filterByMinimumContinuousPower(
    double minimumContinuousPowerW,
  ) {
    if (minimumContinuousPowerW < 0) {
      throw ArgumentError.value(
        minimumContinuousPowerW,
        'minimumContinuousPowerW',
        'Minimum sürekli güç negatif olamaz.',
      );
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where(
        (motor) => motor.continuousPowerW >= minimumContinuousPowerW,
      ),
    );
  }

  List<MotorComponent> filterByPropellerDiameter(double diameterInch) {
    if (diameterInch <= 0) {
      throw ArgumentError.value(
        diameterInch,
        'diameterInch',
        'Pervane çapı sıfırdan büyük olmalıdır.',
      );
    }

    return List<MotorComponent>.unmodifiable(
      _motors.where((motor) => motor.supportsPropellerDiameter(diameterInch)),
    );
  }

  @override
  bool containsId(String id) {
    return findById(id) != null;
  }

  @override
  int get count => _motors.length;

  @override
  bool get isEmpty => _motors.isEmpty;

  @override
  bool get isNotEmpty => _motors.isNotEmpty;
}
