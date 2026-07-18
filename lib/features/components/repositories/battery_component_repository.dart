import '../models/battery_component.dart';
import 'component_repository.dart';

class BatteryComponentRepository
    implements ComponentRepository<BatteryComponent> {
  final List<BatteryComponent> _batteries;

  BatteryComponentRepository({
    List<BatteryComponent> initialBatteries = const [],
  }) : _batteries = List<BatteryComponent>.unmodifiable(initialBatteries);

  @override
  List<BatteryComponent> getAll() {
    return List<BatteryComponent>.unmodifiable(_batteries);
  }

  @override
  BatteryComponent? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final battery in _batteries) {
      if (battery.id == normalizedId) {
        return battery;
      }
    }

    return null;
  }

  @override
  List<BatteryComponent> searchByModel(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where((battery) {
        final searchableText = [
          battery.manufacturer,
          battery.model,
          battery.displayName,
          battery.chemistry,
          '${battery.cellCount}s',
          battery.capacityMah.toStringAsFixed(0),
          battery.nominalVoltageV.toStringAsFixed(1),
        ].join(' ').toLowerCase();

        return searchableText.contains(normalizedQuery);
      }),
    );
  }

  @override
  List<BatteryComponent> filterByManufacturer(String manufacturer) {
    final normalizedManufacturer = manufacturer.trim().toLowerCase();

    if (normalizedManufacturer.isEmpty) {
      return getAll();
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) =>
            battery.manufacturer.trim().toLowerCase() == normalizedManufacturer,
      ),
    );
  }

  List<BatteryComponent> filterByChemistry(String chemistry) {
    final normalizedChemistry = chemistry.trim().toUpperCase();

    if (normalizedChemistry.isEmpty) {
      return getAll();
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) =>
            _normalizeChemistry(battery.chemistry) ==
            _normalizeChemistry(normalizedChemistry),
      ),
    );
  }

  List<BatteryComponent> filterByCellCount(int cellCount) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where((battery) => battery.cellCount == cellCount),
    );
  }

  List<BatteryComponent> filterByCapacityRange({
    required double minimumCapacityMah,
    required double maximumCapacityMah,
  }) {
    if (minimumCapacityMah <= 0 || maximumCapacityMah <= 0) {
      throw ArgumentError('Kapasite filtreleri sıfırdan büyük olmalıdır.');
    }

    if (minimumCapacityMah > maximumCapacityMah) {
      throw ArgumentError('Minimum kapasite maksimum değerden büyük olamaz.');
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) =>
            battery.capacityMah >= minimumCapacityMah &&
            battery.capacityMah <= maximumCapacityMah,
      ),
    );
  }

  List<BatteryComponent> filterByNominalVoltageRange({
    required double minimumVoltageV,
    required double maximumVoltageV,
  }) {
    if (minimumVoltageV <= 0 || maximumVoltageV <= 0) {
      throw ArgumentError('Voltaj filtreleri sıfırdan büyük olmalıdır.');
    }

    if (minimumVoltageV > maximumVoltageV) {
      throw ArgumentError('Minimum voltaj maksimum değerden büyük olamaz.');
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) =>
            battery.nominalVoltageV >= minimumVoltageV &&
            battery.nominalVoltageV <= maximumVoltageV,
      ),
    );
  }

  List<BatteryComponent> filterByMinimumContinuousCurrent(
    double minimumCurrentA,
  ) {
    if (minimumCurrentA < 0) {
      throw ArgumentError.value(
        minimumCurrentA,
        'minimumCurrentA',
        'Minimum akım negatif olamaz.',
      );
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) => battery.maximumContinuousCurrentA >= minimumCurrentA,
      ),
    );
  }

  List<BatteryComponent> filterByMinimumBurstCurrent(double minimumCurrentA) {
    if (minimumCurrentA < 0) {
      throw ArgumentError.value(
        minimumCurrentA,
        'minimumCurrentA',
        'Minimum burst akımı negatif olamaz.',
      );
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) => battery.maximumBurstCurrentA >= minimumCurrentA,
      ),
    );
  }

  List<BatteryComponent> filterByMinimumEnergy(double minimumEnergyWh) {
    if (minimumEnergyWh < 0) {
      throw ArgumentError.value(
        minimumEnergyWh,
        'minimumEnergyWh',
        'Minimum enerji negatif olamaz.',
      );
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where((battery) => battery.nominalEnergyWh >= minimumEnergyWh),
    );
  }

  List<BatteryComponent> filterByMaximumWeight(double maximumWeightG) {
    if (maximumWeightG <= 0) {
      throw ArgumentError.value(
        maximumWeightG,
        'maximumWeightG',
        'Maksimum ağırlık sıfırdan büyük olmalıdır.',
      );
    }

    return List<BatteryComponent>.unmodifiable(
      _batteries.where((battery) => battery.weightG <= maximumWeightG),
    );
  }

  List<BatteryComponent> filterByRequiredPower({
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

    return List<BatteryComponent>.unmodifiable(
      _batteries.where(
        (battery) => battery.supportsRequiredPower(
          requiredPowerW: requiredPowerW,
          loadedVoltageV: loadedVoltageV,
        ),
      ),
    );
  }

  @override
  bool containsId(String id) {
    return findById(id) != null;
  }

  @override
  int get count => _batteries.length;

  @override
  bool get isEmpty => _batteries.isEmpty;

  @override
  bool get isNotEmpty => _batteries.isNotEmpty;

  String _normalizeChemistry(String chemistry) {
    final normalized = chemistry.trim().toUpperCase();

    if (normalized == 'LIION') {
      return 'LI-ION';
    }

    return normalized;
  }
}
