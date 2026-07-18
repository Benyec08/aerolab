import '../models/motor_propeller_combination.dart';
import 'component_repository.dart';

class MotorPropellerCombinationRepository
    implements ComponentRepository<MotorPropellerCombination> {
  final List<MotorPropellerCombination> _combinations;

  MotorPropellerCombinationRepository({
    List<MotorPropellerCombination> initialCombinations = const [],
  }) : _combinations = List<MotorPropellerCombination>.unmodifiable(
         initialCombinations,
       );

  @override
  List<MotorPropellerCombination> getAll() {
    return List<MotorPropellerCombination>.unmodifiable(_combinations);
  }

  @override
  MotorPropellerCombination? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final combination in _combinations) {
      if (combination.id == normalizedId) {
        return combination;
      }
    }

    return null;
  }

  @override
  List<MotorPropellerCombination> searchByModel(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where((combination) {
        final searchableText = [
          combination.motorComponentId,
          combination.propellerComponentId,
          combination.dataSource,
          combination.testDate,
          combination.testConditions,
          combination.notes,
        ].join(' ').toLowerCase();

        return searchableText.contains(normalizedQuery);
      }),
    );
  }

  @override
  List<MotorPropellerCombination> filterByManufacturer(String manufacturer) {
    final normalizedManufacturer = manufacturer.trim().toLowerCase();

    if (normalizedManufacturer.isEmpty) {
      return getAll();
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.dataSource.trim().toLowerCase().contains(
          normalizedManufacturer,
        ),
      ),
    );
  }

  List<MotorPropellerCombination> filterByMotorId(String motorComponentId) {
    final normalizedMotorId = motorComponentId.trim();

    if (normalizedMotorId.isEmpty) {
      return getAll();
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.motorComponentId == normalizedMotorId,
      ),
    );
  }

  List<MotorPropellerCombination> filterByPropellerId(
    String propellerComponentId,
  ) {
    final normalizedPropellerId = propellerComponentId.trim();

    if (normalizedPropellerId.isEmpty) {
      return getAll();
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) =>
            combination.propellerComponentId == normalizedPropellerId,
      ),
    );
  }

  MotorPropellerCombination? findByMotorAndPropeller({
    required String motorComponentId,
    required String propellerComponentId,
  }) {
    final normalizedMotorId = motorComponentId.trim();
    final normalizedPropellerId = propellerComponentId.trim();

    if (normalizedMotorId.isEmpty || normalizedPropellerId.isEmpty) {
      return null;
    }

    for (final combination in _combinations) {
      if (combination.motorComponentId == normalizedMotorId &&
          combination.propellerComponentId == normalizedPropellerId) {
        return combination;
      }
    }

    return null;
  }

  List<MotorPropellerCombination> filterByMinimumThrust(double minimumThrustN) {
    if (minimumThrustN < 0) {
      throw ArgumentError.value(
        minimumThrustN,
        'minimumThrustN',
        'Minimum itki negatif olamaz.',
      );
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.maximumThrustN >= minimumThrustN,
      ),
    );
  }

  List<MotorPropellerCombination> filterByMaximumCurrent(
    double maximumCurrentA,
  ) {
    if (maximumCurrentA <= 0) {
      throw ArgumentError.value(
        maximumCurrentA,
        'maximumCurrentA',
        'Maksimum akım sıfırdan büyük olmalıdır.',
      );
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.maximumCurrentA <= maximumCurrentA,
      ),
    );
  }

  List<MotorPropellerCombination> filterByMaximumPower(double maximumPowerW) {
    if (maximumPowerW <= 0) {
      throw ArgumentError.value(
        maximumPowerW,
        'maximumPowerW',
        'Maksimum güç sıfırdan büyük olmalıdır.',
      );
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.maximumElectricalPowerW <= maximumPowerW,
      ),
    );
  }

  List<MotorPropellerCombination> filterByVoltage(
    double voltageV, {
    double toleranceV = 0.1,
  }) {
    if (voltageV <= 0) {
      throw ArgumentError.value(
        voltageV,
        'voltageV',
        'Voltaj sıfırdan büyük olmalıdır.',
      );
    }

    if (toleranceV < 0) {
      throw ArgumentError.value(
        toleranceV,
        'toleranceV',
        'Voltaj toleransı negatif olamaz.',
      );
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.performancePoints.any(
          (point) => (point.voltageV - voltageV).abs() <= toleranceV,
        ),
      ),
    );
  }

  List<MotorPropellerCombination> filterByDataSource(String dataSource) {
    final normalizedDataSource = dataSource.trim().toLowerCase();

    if (normalizedDataSource.isEmpty) {
      return getAll();
    }

    return List<MotorPropellerCombination>.unmodifiable(
      _combinations.where(
        (combination) => combination.dataSource.trim().toLowerCase().contains(
          normalizedDataSource,
        ),
      ),
    );
  }

  @override
  bool containsId(String id) {
    return findById(id) != null;
  }

  @override
  int get count => _combinations.length;

  @override
  bool get isEmpty => _combinations.isEmpty;

  @override
  bool get isNotEmpty => _combinations.isNotEmpty;
}
