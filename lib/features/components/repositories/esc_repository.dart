import '../models/esc_component.dart';
import 'component_repository.dart';

class EscRepository implements ComponentRepository<EscComponent> {
  final List<EscComponent> _escs;

  EscRepository({List<EscComponent> initialEscs = const []})
    : _escs = List<EscComponent>.unmodifiable(initialEscs);

  @override
  List<EscComponent> getAll() {
    return List<EscComponent>.unmodifiable(_escs);
  }

  @override
  EscComponent? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final esc in _escs) {
      if (esc.id == normalizedId) {
        return esc;
      }
    }

    return null;
  }

  @override
  List<EscComponent> searchByModel(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) {
        final searchableText = [
          esc.manufacturer,
          esc.model,
          esc.displayName,
          esc.continuousCurrentA.toStringAsFixed(0),
          esc.burstCurrentA.toStringAsFixed(0),
          '${esc.maximumSupportedCellCount}s',
          esc.hasBec ? 'bec' : 'opto',
        ].join(' ').toLowerCase();

        return searchableText.contains(normalizedQuery);
      }),
    );
  }

  @override
  List<EscComponent> filterByManufacturer(String manufacturer) {
    final normalizedManufacturer = manufacturer.trim().toLowerCase();

    if (normalizedManufacturer.isEmpty) {
      return getAll();
    }

    return List<EscComponent>.unmodifiable(
      _escs.where(
        (esc) =>
            esc.manufacturer.trim().toLowerCase() == normalizedManufacturer,
      ),
    );
  }

  List<EscComponent> filterByCellCount(int cellCount) {
    if (cellCount <= 0) {
      throw ArgumentError.value(
        cellCount,
        'cellCount',
        'Hücre sayısı sıfırdan büyük olmalıdır.',
      );
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.supportsCellCount(cellCount)),
    );
  }

  List<EscComponent> filterByMinimumContinuousCurrent(double minimumCurrentA) {
    if (minimumCurrentA < 0) {
      throw ArgumentError.value(
        minimumCurrentA,
        'minimumCurrentA',
        'Minimum sürekli akım negatif olamaz.',
      );
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.continuousCurrentA >= minimumCurrentA),
    );
  }

  List<EscComponent> filterByMinimumBurstCurrent(double minimumCurrentA) {
    if (minimumCurrentA < 0) {
      throw ArgumentError.value(
        minimumCurrentA,
        'minimumCurrentA',
        'Minimum burst akımı negatif olamaz.',
      );
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.burstCurrentA >= minimumCurrentA),
    );
  }

  List<EscComponent> filterByEfficiencyRange({
    required double minimumEfficiency,
    required double maximumEfficiency,
  }) {
    if (minimumEfficiency <= 0 ||
        maximumEfficiency <= 0 ||
        minimumEfficiency > 1 ||
        maximumEfficiency > 1) {
      throw ArgumentError('ESC verim filtreleri 0 ile 1 arasında olmalıdır.');
    }

    if (minimumEfficiency > maximumEfficiency) {
      throw ArgumentError('Minimum ESC verimi maksimum değerden büyük olamaz.');
    }

    return List<EscComponent>.unmodifiable(
      _escs.where(
        (esc) =>
            esc.efficiency >= minimumEfficiency &&
            esc.efficiency <= maximumEfficiency,
      ),
    );
  }

  List<EscComponent> filterByMaximumWeight(double maximumWeightG) {
    if (maximumWeightG <= 0) {
      throw ArgumentError.value(
        maximumWeightG,
        'maximumWeightG',
        'Maksimum ağırlık sıfırdan büyük olmalıdır.',
      );
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.weightG <= maximumWeightG),
    );
  }

  List<EscComponent> filterByBecAvailability(bool hasBec) {
    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.hasBec == hasBec),
    );
  }

  List<EscComponent> filterByMinimumBecCurrent(double minimumBecCurrentA) {
    if (minimumBecCurrentA < 0) {
      throw ArgumentError.value(
        minimumBecCurrentA,
        'minimumBecCurrentA',
        'Minimum BEC akımı negatif olamaz.',
      );
    }

    return List<EscComponent>.unmodifiable(
      _escs.where((esc) => esc.hasBec && esc.becCurrentA >= minimumBecCurrentA),
    );
  }

  List<EscComponent> filterByRequiredCurrent({
    required double continuousCurrentA,
    required double burstCurrentA,
  }) {
    if (continuousCurrentA < 0 || burstCurrentA < 0) {
      throw ArgumentError('Gerekli ESC akım değerleri negatif olamaz.');
    }

    if (continuousCurrentA > burstCurrentA) {
      throw ArgumentError('Gerekli sürekli akım burst akımından büyük olamaz.');
    }

    return List<EscComponent>.unmodifiable(
      _escs.where(
        (esc) =>
            esc.supportsContinuousCurrent(continuousCurrentA) &&
            esc.supportsBurstCurrent(burstCurrentA),
      ),
    );
  }

  @override
  bool containsId(String id) {
    return findById(id) != null;
  }

  @override
  int get count => _escs.length;

  @override
  bool get isEmpty => _escs.isEmpty;

  @override
  bool get isNotEmpty => _escs.isNotEmpty;
}
