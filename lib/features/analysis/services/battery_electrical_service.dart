import 'dart:math' as math;

/// Batarya paketinin yük altındaki elektriksel davranışını hesaplar.
///
/// Kullanılan temel model:
///
/// P = I × V_loaded
///
/// V_loaded = V_openCircuit - I × R_pack
///
/// Birleştirildiğinde:
///
/// P = I × (V_openCircuit - I × R_pack)
///
/// Bu denklem ikinci derece denklem olarak çözülür.
class BatteryElectricalService {
  BatteryElectricalResult calculate({
    required double requestedPowerW,
    required double openCircuitVoltageV,
    required double packInternalResistanceOhm,
    required double capacityAh,
  }) {
    _validateInputs(
      requestedPowerW: requestedPowerW,
      openCircuitVoltageV: openCircuitVoltageV,
      packInternalResistanceOhm: packInternalResistanceOhm,
      capacityAh: capacityAh,
    );

    if (requestedPowerW == 0) {
      return BatteryElectricalResult(
        requestedPowerW: 0,
        openCircuitVoltageV: openCircuitVoltageV,
        loadedVoltageV: openCircuitVoltageV,
        voltageSagV: 0,
        currentA: 0,
        cRate: 0,
        internalResistancePowerLossW: 0,
        maximumDeliverablePowerW: _maximumDeliverablePower(
          openCircuitVoltageV,
          packInternalResistanceOhm,
        ),
        canDeliverRequestedPower: true,
      );
    }

    if (packInternalResistanceOhm == 0) {
      final currentA = requestedPowerW / openCircuitVoltageV;

      return BatteryElectricalResult(
        requestedPowerW: requestedPowerW,
        openCircuitVoltageV: openCircuitVoltageV,
        loadedVoltageV: openCircuitVoltageV,
        voltageSagV: 0,
        currentA: currentA,
        cRate: currentA / capacityAh,
        internalResistancePowerLossW: 0,
        maximumDeliverablePowerW: double.infinity,
        canDeliverRequestedPower: true,
      );
    }

    final maximumDeliverablePowerW = _maximumDeliverablePower(
      openCircuitVoltageV,
      packInternalResistanceOhm,
    );

    final discriminant =
        openCircuitVoltageV * openCircuitVoltageV -
        4 * packInternalResistanceOhm * requestedPowerW;

    if (discriminant < 0) {
      return BatteryElectricalResult(
        requestedPowerW: requestedPowerW,
        openCircuitVoltageV: openCircuitVoltageV,
        loadedVoltageV: 0,
        voltageSagV: openCircuitVoltageV,
        currentA: openCircuitVoltageV / (2 * packInternalResistanceOhm),
        cRate:
            openCircuitVoltageV / (2 * packInternalResistanceOhm * capacityAh),
        internalResistancePowerLossW: maximumDeliverablePowerW,
        maximumDeliverablePowerW: maximumDeliverablePowerW,
        canDeliverRequestedPower: false,
      );
    }

    final currentA =
        (openCircuitVoltageV - math.sqrt(discriminant)) /
        (2 * packInternalResistanceOhm);

    final voltageSagV = currentA * packInternalResistanceOhm;
    final loadedVoltageV = openCircuitVoltageV - voltageSagV;

    final internalResistancePowerLossW =
        currentA * currentA * packInternalResistanceOhm;

    return BatteryElectricalResult(
      requestedPowerW: requestedPowerW,
      openCircuitVoltageV: openCircuitVoltageV,
      loadedVoltageV: loadedVoltageV,
      voltageSagV: voltageSagV,
      currentA: currentA,
      cRate: currentA / capacityAh,
      internalResistancePowerLossW: internalResistancePowerLossW,
      maximumDeliverablePowerW: maximumDeliverablePowerW,
      canDeliverRequestedPower: true,
    );
  }

  double _maximumDeliverablePower(
    double openCircuitVoltageV,
    double packInternalResistanceOhm,
  ) {
    if (packInternalResistanceOhm == 0) {
      return double.infinity;
    }

    return openCircuitVoltageV *
        openCircuitVoltageV /
        (4 * packInternalResistanceOhm);
  }

  void _validateInputs({
    required double requestedPowerW,
    required double openCircuitVoltageV,
    required double packInternalResistanceOhm,
    required double capacityAh,
  }) {
    if (!requestedPowerW.isFinite || requestedPowerW < 0) {
      throw ArgumentError.value(
        requestedPowerW,
        'requestedPowerW',
        'İstenen güç sıfır veya pozitif olmalıdır.',
      );
    }

    if (!openCircuitVoltageV.isFinite || openCircuitVoltageV <= 0) {
      throw ArgumentError.value(
        openCircuitVoltageV,
        'openCircuitVoltageV',
        'Açık devre voltajı sıfırdan büyük olmalıdır.',
      );
    }

    if (!packInternalResistanceOhm.isFinite || packInternalResistanceOhm < 0) {
      throw ArgumentError.value(
        packInternalResistanceOhm,
        'packInternalResistanceOhm',
        'Paket iç direnci sıfır veya pozitif olmalıdır.',
      );
    }

    if (!capacityAh.isFinite || capacityAh <= 0) {
      throw ArgumentError.value(
        capacityAh,
        'capacityAh',
        'Batarya kapasitesi sıfırdan büyük olmalıdır.',
      );
    }
  }
}

class BatteryElectricalResult {
  final double requestedPowerW;
  final double openCircuitVoltageV;
  final double loadedVoltageV;
  final double voltageSagV;
  final double currentA;
  final double cRate;
  final double internalResistancePowerLossW;
  final double maximumDeliverablePowerW;
  final bool canDeliverRequestedPower;

  const BatteryElectricalResult({
    required this.requestedPowerW,
    required this.openCircuitVoltageV,
    required this.loadedVoltageV,
    required this.voltageSagV,
    required this.currentA,
    required this.cRate,
    required this.internalResistancePowerLossW,
    required this.maximumDeliverablePowerW,
    required this.canDeliverRequestedPower,
  });
}
