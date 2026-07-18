import '../models/propeller_component.dart';
import 'component_repository.dart';

class PropellerRepository implements ComponentRepository<PropellerComponent> {
  final List<PropellerComponent> _propellers;

  PropellerRepository({List<PropellerComponent> initialPropellers = const []})
    : _propellers = List<PropellerComponent>.unmodifiable(initialPropellers);

  @override
  List<PropellerComponent> getAll() {
    return List<PropellerComponent>.unmodifiable(_propellers);
  }

  @override
  PropellerComponent? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final propeller in _propellers) {
      if (propeller.id == normalizedId) {
        return propeller;
      }
    }

    return null;
  }

  @override
  List<PropellerComponent> searchByModel(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where((propeller) {
        final searchableText = [
          propeller.manufacturer,
          propeller.model,
          propeller.displayName,
          propeller.material,
          propeller.diameterInch.toStringAsFixed(1),
          propeller.pitchInch.toStringAsFixed(1),
        ].join(' ').toLowerCase();

        return searchableText.contains(normalizedQuery);
      }),
    );
  }

  @override
  List<PropellerComponent> filterByManufacturer(String manufacturer) {
    final normalizedManufacturer = manufacturer.trim().toLowerCase();

    if (normalizedManufacturer.isEmpty) {
      return getAll();
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where(
        (propeller) =>
            propeller.manufacturer.trim().toLowerCase() ==
            normalizedManufacturer,
      ),
    );
  }

  List<PropellerComponent> filterByDiameterRange({
    required double minimumDiameterInch,
    required double maximumDiameterInch,
  }) {
    if (minimumDiameterInch <= 0 || maximumDiameterInch <= 0) {
      throw ArgumentError('Pervane çap filtreleri sıfırdan büyük olmalıdır.');
    }

    if (minimumDiameterInch > maximumDiameterInch) {
      throw ArgumentError(
        'Minimum pervane çapı maksimum değerden büyük olamaz.',
      );
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where(
        (propeller) =>
            propeller.diameterInch >= minimumDiameterInch &&
            propeller.diameterInch <= maximumDiameterInch,
      ),
    );
  }

  List<PropellerComponent> filterByPitchRange({
    required double minimumPitchInch,
    required double maximumPitchInch,
  }) {
    if (minimumPitchInch <= 0 || maximumPitchInch <= 0) {
      throw ArgumentError('Pitch filtreleri sıfırdan büyük olmalıdır.');
    }

    if (minimumPitchInch > maximumPitchInch) {
      throw ArgumentError('Minimum pitch maksimum değerden büyük olamaz.');
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where(
        (propeller) =>
            propeller.pitchInch >= minimumPitchInch &&
            propeller.pitchInch <= maximumPitchInch,
      ),
    );
  }

  List<PropellerComponent> filterByBladeCount(int bladeCount) {
    if (bladeCount < 2) {
      throw ArgumentError.value(
        bladeCount,
        'bladeCount',
        'Pervane kanat sayısı en az iki olmalıdır.',
      );
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where((propeller) => propeller.bladeCount == bladeCount),
    );
  }

  List<PropellerComponent> filterByMaterial(String material) {
    final normalizedMaterial = material.trim().toLowerCase();

    if (normalizedMaterial.isEmpty) {
      return getAll();
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where(
        (propeller) =>
            propeller.material.trim().toLowerCase() == normalizedMaterial,
      ),
    );
  }

  List<PropellerComponent> filterByMotorKv(double kvRating) {
    if (kvRating <= 0) {
      throw ArgumentError.value(
        kvRating,
        'kvRating',
        'Motor KV değeri sıfırdan büyük olmalıdır.',
      );
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where((propeller) => propeller.supportsMotorKv(kvRating)),
    );
  }

  List<PropellerComponent> filterByVoltage(double voltageV) {
    if (voltageV <= 0) {
      throw ArgumentError.value(
        voltageV,
        'voltageV',
        'Voltaj sıfırdan büyük olmalıdır.',
      );
    }

    return List<PropellerComponent>.unmodifiable(
      _propellers.where((propeller) => propeller.supportsVoltage(voltageV)),
    );
  }

  List<PropellerComponent> filterByRotationDirection(String rotationDirection) {
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

    return List<PropellerComponent>.unmodifiable(
      _propellers.where((propeller) {
        final componentDirection = propeller.rotationDirection
            .trim()
            .toUpperCase();

        return componentDirection == 'CW/CCW' ||
            componentDirection == normalizedDirection;
      }),
    );
  }

  @override
  bool containsId(String id) {
    return findById(id) != null;
  }

  @override
  int get count => _propellers.length;

  @override
  bool get isEmpty => _propellers.isEmpty;

  @override
  bool get isNotEmpty => _propellers.isNotEmpty;
}
