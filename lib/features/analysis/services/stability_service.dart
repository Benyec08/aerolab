import '../models/stability_result.dart';

class MassStation {
  final String name;
  final double massKg;
  final double armFromDatumM;

  const MassStation({
    required this.name,
    required this.massKg,
    required this.armFromDatumM,
  });
}

class StabilityService {
  const StabilityService();

  StabilityResult calculate({
    required List<MassStation> massStations,
    required double meanAerodynamicChordM,
    required double macLeadingEdgeFromDatumM,
    required double neutralPointPercentMac,
    required double minimumCgPercentMac,
    required double maximumCgPercentMac,
  }) {
    if (!_inputsAreValid(
      massStations: massStations,
      meanAerodynamicChordM: meanAerodynamicChordM,
      macLeadingEdgeFromDatumM: macLeadingEdgeFromDatumM,
      neutralPointPercentMac: neutralPointPercentMac,
      minimumCgPercentMac: minimumCgPercentMac,
      maximumCgPercentMac: maximumCgPercentMac,
    )) {
      return const StabilityResult.notApplicable(
        message:
            'CG hesabı için bileşen kütleleri, moment kolları, MAC ve '
            'nötr nokta girdileri geçerli olmalıdır.',
      );
    }

    final totalMassKg = massStations.fold<double>(
      0.0,
      (sum, station) => sum + station.massKg,
    );

    final totalMomentKgM = massStations.fold<double>(
      0.0,
      (sum, station) => sum + station.massKg * station.armFromDatumM,
    );

    final centerOfGravityFromDatumM = totalMomentKgM / totalMassKg;

    final centerOfGravityFromLeadingEdgeM =
        centerOfGravityFromDatumM - macLeadingEdgeFromDatumM;

    final centerOfGravityPercentMac =
        centerOfGravityFromLeadingEdgeM / meanAerodynamicChordM * 100.0;

    final neutralPointFromLeadingEdgeM =
        neutralPointPercentMac / 100.0 * meanAerodynamicChordM;

    final staticMarginPercent =
        neutralPointPercentMac - centerOfGravityPercentMac;

    final isCenterOfGravityWithinLimits =
        centerOfGravityPercentMac >= minimumCgPercentMac &&
        centerOfGravityPercentMac <= maximumCgPercentMac;

    final isStaticallyStable = staticMarginPercent > 0.0;

    final status = _buildStatus(
      staticMarginPercent: staticMarginPercent,
      isCenterOfGravityWithinLimits: isCenterOfGravityWithinLimits,
    );

    final message = _buildMessage(
      centerOfGravityPercentMac: centerOfGravityPercentMac,
      staticMarginPercent: staticMarginPercent,
      isCenterOfGravityWithinLimits: isCenterOfGravityWithinLimits,
      isStaticallyStable: isStaticallyStable,
    );

    return StabilityResult(
      isApplicable: true,
      centerOfGravityFromLeadingEdgeM: centerOfGravityFromLeadingEdgeM,
      centerOfGravityPercentMac: centerOfGravityPercentMac,
      neutralPointFromLeadingEdgeM: neutralPointFromLeadingEdgeM,
      neutralPointPercentMac: neutralPointPercentMac,
      staticMarginPercent: staticMarginPercent,
      isCenterOfGravityWithinLimits: isCenterOfGravityWithinLimits,
      isStaticallyStable: isStaticallyStable,
      status: status,
      message: message,
    );
  }

  bool _inputsAreValid({
    required List<MassStation> massStations,
    required double meanAerodynamicChordM,
    required double macLeadingEdgeFromDatumM,
    required double neutralPointPercentMac,
    required double minimumCgPercentMac,
    required double maximumCgPercentMac,
  }) {
    if (massStations.isEmpty ||
        !meanAerodynamicChordM.isFinite ||
        !macLeadingEdgeFromDatumM.isFinite ||
        !neutralPointPercentMac.isFinite ||
        !minimumCgPercentMac.isFinite ||
        !maximumCgPercentMac.isFinite ||
        meanAerodynamicChordM <= 0.0 ||
        neutralPointPercentMac <= 0.0 ||
        neutralPointPercentMac > 100.0 ||
        minimumCgPercentMac < 0.0 ||
        maximumCgPercentMac > 100.0 ||
        minimumCgPercentMac >= maximumCgPercentMac) {
      return false;
    }

    return massStations.every(
      (station) =>
          station.name.trim().isNotEmpty &&
          station.massKg.isFinite &&
          station.armFromDatumM.isFinite &&
          station.massKg > 0.0,
    );
  }

  String _buildStatus({
    required double staticMarginPercent,
    required bool isCenterOfGravityWithinLimits,
  }) {
    if (!isCenterOfGravityWithinLimits) {
      return 'CG Limit Dışı';
    }

    if (staticMarginPercent <= 0.0) {
      return 'Kararsız';
    }

    if (staticMarginPercent < 5.0) {
      return 'Düşük Statik Marj';
    }

    if (staticMarginPercent <= 15.0) {
      return 'Kararlı';
    }

    return 'Aşırı Kararlı';
  }

  String _buildMessage({
    required double centerOfGravityPercentMac,
    required double staticMarginPercent,
    required bool isCenterOfGravityWithinLimits,
    required bool isStaticallyStable,
  }) {
    if (!isCenterOfGravityWithinLimits) {
      return 'Ağırlık merkezi '
          '${centerOfGravityPercentMac.toStringAsFixed(1)}% MAC '
          'konumundadır ve tanımlanan güvenli CG limitlerinin dışındadır.';
    }

    if (!isStaticallyStable) {
      return 'Statik marj '
          '${staticMarginPercent.toStringAsFixed(1)}% değerindedir. '
          'Nötr nokta CG konumunun önünde olmadığı için araç boylamsal '
          'olarak statik kararlı değildir.';
    }

    return 'Ağırlık merkezi '
        '${centerOfGravityPercentMac.toStringAsFixed(1)}% MAC, '
        'statik marj ${staticMarginPercent.toStringAsFixed(1)}% '
        'olarak hesaplanmıştır.';
  }
}
