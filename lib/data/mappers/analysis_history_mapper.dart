import 'dart:convert';

import '../entities/analysis_history_entity.dart';
import '../../features/analysis/models/aircraft.dart';
import '../../features/analysis/models/aircraft_mass_station.dart';
import '../../features/analysis/models/analysis_result.dart';
import '../../features/analysis/models/climb_performance_result.dart';
import '../../features/analysis/models/endurance_range_result.dart';
import '../../features/analysis/models/environment.dart';
import '../../features/analysis/models/flight_envelope_result.dart';
import '../../features/analysis/models/glide_performance_result.dart';
import '../../features/analysis/models/stability_result.dart';

class AnalysisHistoryMapper {
  const AnalysisHistoryMapper();

  AnalysisHistoryEntity toEntity({
    required Aircraft aircraft,
    required Environment environment,
    required AnalysisResult result,
  }) {
    return AnalysisHistoryEntity.create(
      aircraftName: aircraft.name,
      aircraftType: aircraft.type,
      aircraftDataJson: _encode(aircraftToMap(aircraft)),
      environmentDataJson: _encode(environmentToMap(environment)),
      resultDataJson: _encode(resultToMap(result)),
    );
  }

  Aircraft restoreAircraft(AnalysisHistoryEntity entity) {
    return aircraftFromMap(_decode(entity.aircraftDataJson));
  }

  Environment restoreEnvironment(AnalysisHistoryEntity entity) {
    return environmentFromMap(_decode(entity.environmentDataJson));
  }

  AnalysisResult restoreResult(AnalysisHistoryEntity entity) {
    return resultFromMap(_decode(entity.resultDataJson));
  }

  Map<String, dynamic> aircraftToMap(Aircraft value) {
    return {
      'name': value.name,
      'type': value.type,
      'weightKg': value.weightKg,
      'wingAreaM2': value.wingAreaM2,
      'wingSpanM': value.wingSpanM,
      'motorCount': value.motorCount,
      'motorPowerW': value.motorPowerW,
      'propellerDiameterInch': value.propellerDiameterInch,
      'batteryCapacityMah': value.batteryCapacityMah,
      'batteryVoltageV': value.batteryVoltageV,
      'batteryType': value.batteryType,
      'batteryCellCount': value.batteryCellCount,
      'motorComponentId': value.motorComponentId,
      'propellerComponentId': value.propellerComponentId,
      'batteryComponentId': value.batteryComponentId,
      'escComponentId': value.escComponentId,
      'motorPropellerCombinationId': value.motorPropellerCombinationId,
      'cellInternalResistanceMilliOhm': value.cellInternalResistanceMilliOhm,
      'cruiseSpeedMs': value.cruiseSpeedMs,
      'zeroLiftDragCoefficient': value.zeroLiftDragCoefficient,
      'maxLiftCoefficient': value.maxLiftCoefficient,
      'oswaldEfficiencyFactor': value.oswaldEfficiencyFactor,
      'escEfficiency': value.escEfficiency,
      'motorEfficiency': value.motorEfficiency,
      'continuousMotorPowerW': value.continuousMotorPowerW,
      'maximumMotorPowerW': value.maximumMotorPowerW,
      'massStations': value.massStations
          .map((station) => station.toMap())
          .toList(),
      'meanAerodynamicChordM': value.meanAerodynamicChordM,
      'macLeadingEdgeFromDatumM': value.macLeadingEdgeFromDatumM,
      'neutralPointPercentMac': value.neutralPointPercentMac,
      'minimumCgPercentMac': value.minimumCgPercentMac,
      'maximumCgPercentMac': value.maximumCgPercentMac,
      'maximumOperatingSpeedMs': value.maximumOperatingSpeedMs,
      'positiveLimitLoadFactor': value.positiveLimitLoadFactor,
      'negativeLimitLoadFactor': value.negativeLimitLoadFactor,
    };
  }

  Aircraft aircraftFromMap(Map<String, dynamic> map) {
    return Aircraft(
      name: _string(map['name']),
      type: _string(map['type']),
      weightKg: _double(map['weightKg']),
      wingAreaM2: _double(map['wingAreaM2']),
      wingSpanM: _double(map['wingSpanM']),
      motorCount: _int(map['motorCount']),
      motorPowerW: _double(map['motorPowerW']),
      propellerDiameterInch: _double(map['propellerDiameterInch']),
      batteryCapacityMah: _double(map['batteryCapacityMah']),
      batteryVoltageV: _double(map['batteryVoltageV']),
      batteryType: _string(map['batteryType']),
      batteryCellCount: _int(map['batteryCellCount']),
      motorComponentId: _nullableString(map['motorComponentId']),
      propellerComponentId: _nullableString(map['propellerComponentId']),
      batteryComponentId: _nullableString(map['batteryComponentId']),
      escComponentId: _nullableString(map['escComponentId']),
      motorPropellerCombinationId: _nullableString(
        map['motorPropellerCombinationId'],
      ),
      cellInternalResistanceMilliOhm: _double(
        map['cellInternalResistanceMilliOhm'],
      ),
      cruiseSpeedMs: _double(map['cruiseSpeedMs']),
      zeroLiftDragCoefficient: _double(map['zeroLiftDragCoefficient']),
      maxLiftCoefficient: _double(map['maxLiftCoefficient']),
      oswaldEfficiencyFactor: _double(map['oswaldEfficiencyFactor']),
      escEfficiency: _double(map['escEfficiency']),
      motorEfficiency: _double(map['motorEfficiency']),
      continuousMotorPowerW: _double(map['continuousMotorPowerW']),
      maximumMotorPowerW: _double(map['maximumMotorPowerW']),
      massStations: (_list(
        map['massStations'],
      )).map((item) => AircraftMassStation.fromMap(_dynamicMap(item))).toList(),
      meanAerodynamicChordM: _double(map['meanAerodynamicChordM']),
      macLeadingEdgeFromDatumM: _double(map['macLeadingEdgeFromDatumM']),
      neutralPointPercentMac: _double(map['neutralPointPercentMac']),
      minimumCgPercentMac: _double(map['minimumCgPercentMac']),
      maximumCgPercentMac: _double(map['maximumCgPercentMac']),
      maximumOperatingSpeedMs: _double(map['maximumOperatingSpeedMs']),
      positiveLimitLoadFactor: _double(map['positiveLimitLoadFactor']),
      negativeLimitLoadFactor: _double(map['negativeLimitLoadFactor']),
    );
  }

  Map<String, dynamic> environmentToMap(Environment value) {
    return {
      'altitudeM': value.altitudeM,
      'temperatureC': value.temperatureC,
      'pressureHpa': value.pressureHpa,
      'humidityPercent': value.humidityPercent,
      'windSpeedKmh': value.windSpeedKmh,
      'windDirection': value.windDirection,
    };
  }

  Environment environmentFromMap(Map<String, dynamic> map) {
    return Environment(
      altitudeM: _double(map['altitudeM']),
      temperatureC: _double(map['temperatureC']),
      pressureHpa: _double(map['pressureHpa']),
      humidityPercent: _double(map['humidityPercent']),
      windSpeedKmh: _double(map['windSpeedKmh']),
      windDirection: _string(map['windDirection']),
    );
  }

  Map<String, dynamic> resultToMap(AnalysisResult value) {
    return {
      'aircraftType': value.aircraftType,
      'hasFixedWingAerodynamics': value.hasFixedWingAerodynamics,
      'liftN': value.liftN,
      'dragN': value.dragN,
      'wingLoading': value.wingLoading,
      'stallSpeed': value.stallSpeed,
      'thrustToWeight': value.thrustToWeight,
      'estimatedFlightTime': value.estimatedFlightTime,
      'aspectRatio': value.aspectRatio,
      'powerToWeight': value.powerToWeight,
      'estimatedThrustN': value.estimatedThrustN,
      'missionPowerModelName': value.missionPowerModelName,
      'hoverPowerW': value.hoverPowerW,
      'cruisePowerW': value.cruisePowerW,
      'averageMissionPowerW': value.averageMissionPowerW,
      'peakMissionPowerW': value.peakMissionPowerW,
      'peakPowerUsageRatio': value.peakPowerUsageRatio,
      'installedPowerReserveW': value.installedPowerReserveW,
      'installedPowerReservePercent': value.installedPowerReservePercent,
      'hasSufficientInstalledPower': value.hasSufficientInstalledPower,
      'averageBatteryCurrentA': value.averageBatteryCurrentA,
      'nominalBatteryEnergyWh': value.nominalBatteryEnergyWh,
      'usableBatteryEnergyWh': value.usableBatteryEnergyWh,
      'cruiseSpeedMs': value.cruiseSpeedMs,
      'dynamicPressurePa': value.dynamicPressurePa,
      'requiredLiftCoefficient': value.requiredLiftCoefficient,
      'dragCoefficient': value.dragCoefficient,
      'inducedDragFactor': value.inducedDragFactor,
      'liftToDragRatio': value.liftToDragRatio,
      'liftCoefficientUsageRatio': value.liftCoefficientUsageRatio,
      'isCruiseAerodynamicallyValid': value.isCruiseAerodynamicallyValid,
      'escOutputPowerW': value.escOutputPowerW,
      'motorShaftPowerW': value.motorShaftPowerW,
      'usefulPropulsivePowerW': value.usefulPropulsivePowerW,
      'totalPropulsionEfficiency': value.totalPropulsionEfficiency,
      'averageContinuousLoadRatio': value.averageContinuousLoadRatio,
      'peakMaximumLoadRatio': value.peakMaximumLoadRatio,
      'continuousPowerReserveW': value.continuousPowerReserveW,
      'maximumPowerReserveW': value.maximumPowerReserveW,
      'isPropulsionSystemSafe': value.isPropulsionSystemSafe,
      'propulsionSystemStatus': value.propulsionSystemStatus,
      'fullPackVoltageV': value.fullPackVoltageV,
      'nominalPackVoltageV': value.nominalPackVoltageV,
      'minimumSafePackVoltageV': value.minimumSafePackVoltageV,
      'packInternalResistanceOhm': value.packInternalResistanceOhm,
      'averageLoadedVoltageV': value.averageLoadedVoltageV,
      'peakLoadedVoltageV': value.peakLoadedVoltageV,
      'averageVoltageSagV': value.averageVoltageSagV,
      'peakVoltageSagV': value.peakVoltageSagV,
      'peakBatteryCurrentA': value.peakBatteryCurrentA,
      'averageCRate': value.averageCRate,
      'peakCRate': value.peakCRate,
      'batteryLoadEfficiency': value.batteryLoadEfficiency,
      'isBatterySystemSafe': value.isBatterySystemSafe,
      'batterySystemStatus': value.batterySystemStatus,
      'batteryScore': value.batteryScore,
      'batteryScoreStatus': value.batteryScoreStatus,
      'batterySafetyMessage': value.batterySafetyMessage,
      'batteryRecommendationTitle': value.batteryRecommendationTitle,
      'batteryRecommendationMessage': value.batteryRecommendationMessage,
      'isBatteryRecommendationSafe': value.isBatteryRecommendationSafe,
      'geometricAltitudeM': value.geometricAltitudeM,
      'environmentTemperatureC': value.environmentTemperatureC,
      'environmentPressureHpa': value.environmentPressureHpa,
      'relativeHumidityPercent': value.relativeHumidityPercent,
      'isaTemperatureC': value.isaTemperatureC,
      'isaPressureHpa': value.isaPressureHpa,
      'isaDensityKgM3': value.isaDensityKgM3,
      'temperatureDeviationC': value.temperatureDeviationC,
      'pressureDeviationHpa': value.pressureDeviationHpa,
      'pressureDeviationPercent': value.pressureDeviationPercent,
      'densityDeviationKgM3': value.densityDeviationKgM3,
      'densityDeviationPercent': value.densityDeviationPercent,
      'saturationVaporPressureHpa': value.saturationVaporPressureHpa,
      'vaporPressureHpa': value.vaporPressureHpa,
      'dryAirPartialPressureHpa': value.dryAirPartialPressureHpa,
      'humidAirDensityKgM3': value.humidAirDensityKgM3,
      'densityAltitudeM': value.densityAltitudeM,
      'densityAltitudeDifferenceM': value.densityAltitudeDifferenceM,
      'atmosphereStatus': value.atmosphereStatus,
      'isAtmosphereWithinSupportedLimits':
          value.isAtmosphereWithinSupportedLimits,
      'windSpeedKmh': value.windSpeedKmh,
      'windSpeedMs': value.windSpeedMs,
      'windDirection': value.windDirection,
      'headwindComponentMs': value.headwindComponentMs,
      'tailwindComponentMs': value.tailwindComponentMs,
      'crosswindComponentMs': value.crosswindComponentMs,
      'crosswindDirection': value.crosswindDirection,
      'commandedAirspeedMs': value.commandedAirspeedMs,
      'effectiveAirspeedMs': value.effectiveAirspeedMs,
      'estimatedGroundSpeedMs': value.estimatedGroundSpeedMs,
      'windIntensityStatus': value.windIntensityStatus,
      'windSafetyStatus': value.windSafetyStatus,
      'isWindWithinSupportedLimits': value.isWindWithinSupportedLimits,
      'usesComponentDatabase': value.usesComponentDatabase,
      'hasRealMotorPropellerData': value.hasRealMotorPropellerData,
      'motorComponentId': value.motorComponentId,
      'propellerComponentId': value.propellerComponentId,
      'motorPropellerCombinationId': value.motorPropellerCombinationId,
      'componentDataSource': value.componentDataSource,
      'componentTestConditions': value.componentTestConditions,
      'realTestMaximumThrustPerMotorN': value.realTestMaximumThrustPerMotorN,
      'realTestTotalMaximumThrustN': value.realTestTotalMaximumThrustN,
      'realTestMaximumCurrentPerMotorA': value.realTestMaximumCurrentPerMotorA,
      'realTestTotalMaximumCurrentA': value.realTestTotalMaximumCurrentA,
      'realTestMaximumPowerPerMotorW': value.realTestMaximumPowerPerMotorW,
      'realTestTotalMaximumPowerW': value.realTestTotalMaximumPowerW,
      'realTestVoltageV': value.realTestVoltageV,
      'realTestThrustToWeight': value.realTestThrustToWeight,
      'componentCompatibilityScore': value.componentCompatibilityScore,
      'componentCompatibilityStatus': value.componentCompatibilityStatus,
      'componentCompatibilityMessage': value.componentCompatibilityMessage,
      'isComponentSelectionCompatible': value.isComponentSelectionCompatible,
      'climbPerformance': value.climbPerformance.toMap(),
      'enduranceRange': value.enduranceRange.toMap(),
      'glidePerformance': value.glidePerformance.toMap(),
      'stability': value.stability.toMap(),
      'flightEnvelope': value.flightEnvelope.toMap(),
      'wingLoadingStatus': value.wingLoadingStatus,
      'powerToWeightStatus': value.powerToWeightStatus,
      'thrustToWeightStatus': value.thrustToWeightStatus,
      'aerodynamicScore': value.aerodynamicScore,
      'propulsionScore': value.propulsionScore,
      'energyScore': value.energyScore,
      'overallScore': value.overallScore,
      'riskScore': value.riskScore,
      'status': value.status,
      'recommendation': value.recommendation,
    };
  }

  AnalysisResult resultFromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      aircraftType: _string(map['aircraftType']),
      hasFixedWingAerodynamics: _bool(map['hasFixedWingAerodynamics']),
      liftN: _double(map['liftN']),
      dragN: _double(map['dragN']),
      wingLoading: _double(map['wingLoading']),
      stallSpeed: _double(map['stallSpeed']),
      thrustToWeight: _double(map['thrustToWeight']),
      estimatedFlightTime: _double(map['estimatedFlightTime']),
      aspectRatio: _double(map['aspectRatio']),
      powerToWeight: _double(map['powerToWeight']),
      estimatedThrustN: _double(map['estimatedThrustN']),
      missionPowerModelName: _string(map['missionPowerModelName']),
      hoverPowerW: _double(map['hoverPowerW']),
      cruisePowerW: _double(map['cruisePowerW']),
      averageMissionPowerW: _double(map['averageMissionPowerW']),
      peakMissionPowerW: _double(map['peakMissionPowerW']),
      peakPowerUsageRatio: _double(map['peakPowerUsageRatio']),
      installedPowerReserveW: _double(map['installedPowerReserveW']),
      installedPowerReservePercent: _double(
        map['installedPowerReservePercent'],
      ),
      hasSufficientInstalledPower: _bool(map['hasSufficientInstalledPower']),
      averageBatteryCurrentA: _double(map['averageBatteryCurrentA']),
      nominalBatteryEnergyWh: _double(map['nominalBatteryEnergyWh']),
      usableBatteryEnergyWh: _double(map['usableBatteryEnergyWh']),
      cruiseSpeedMs: _double(map['cruiseSpeedMs']),
      dynamicPressurePa: _double(map['dynamicPressurePa']),
      requiredLiftCoefficient: _double(map['requiredLiftCoefficient']),
      dragCoefficient: _double(map['dragCoefficient']),
      inducedDragFactor: _double(map['inducedDragFactor']),
      liftToDragRatio: _double(map['liftToDragRatio']),
      liftCoefficientUsageRatio: _double(map['liftCoefficientUsageRatio']),
      isCruiseAerodynamicallyValid: _bool(map['isCruiseAerodynamicallyValid']),
      escOutputPowerW: _double(map['escOutputPowerW']),
      motorShaftPowerW: _double(map['motorShaftPowerW']),
      usefulPropulsivePowerW: _double(map['usefulPropulsivePowerW']),
      totalPropulsionEfficiency: _double(map['totalPropulsionEfficiency']),
      averageContinuousLoadRatio: _double(map['averageContinuousLoadRatio']),
      peakMaximumLoadRatio: _double(map['peakMaximumLoadRatio']),
      continuousPowerReserveW: _double(map['continuousPowerReserveW']),
      maximumPowerReserveW: _double(map['maximumPowerReserveW']),
      isPropulsionSystemSafe: _bool(map['isPropulsionSystemSafe']),
      propulsionSystemStatus: _string(map['propulsionSystemStatus']),
      fullPackVoltageV: _double(map['fullPackVoltageV']),
      nominalPackVoltageV: _double(map['nominalPackVoltageV']),
      minimumSafePackVoltageV: _double(map['minimumSafePackVoltageV']),
      packInternalResistanceOhm: _double(map['packInternalResistanceOhm']),
      averageLoadedVoltageV: _double(map['averageLoadedVoltageV']),
      peakLoadedVoltageV: _double(map['peakLoadedVoltageV']),
      averageVoltageSagV: _double(map['averageVoltageSagV']),
      peakVoltageSagV: _double(map['peakVoltageSagV']),
      peakBatteryCurrentA: _double(map['peakBatteryCurrentA']),
      averageCRate: _double(map['averageCRate']),
      peakCRate: _double(map['peakCRate']),
      batteryLoadEfficiency: _double(map['batteryLoadEfficiency']),
      isBatterySystemSafe: _bool(map['isBatterySystemSafe']),
      batterySystemStatus: _string(map['batterySystemStatus']),
      batteryScore: _int(map['batteryScore']),
      batteryScoreStatus: _string(map['batteryScoreStatus']),
      batterySafetyMessage: _string(map['batterySafetyMessage']),
      batteryRecommendationTitle: _string(map['batteryRecommendationTitle']),
      batteryRecommendationMessage: _string(
        map['batteryRecommendationMessage'],
      ),
      isBatteryRecommendationSafe: _bool(map['isBatteryRecommendationSafe']),
      geometricAltitudeM: _double(map['geometricAltitudeM']),
      environmentTemperatureC: _double(map['environmentTemperatureC']),
      environmentPressureHpa: _double(map['environmentPressureHpa']),
      relativeHumidityPercent: _double(map['relativeHumidityPercent']),
      isaTemperatureC: _double(map['isaTemperatureC']),
      isaPressureHpa: _double(map['isaPressureHpa']),
      isaDensityKgM3: _double(map['isaDensityKgM3']),
      temperatureDeviationC: _double(map['temperatureDeviationC']),
      pressureDeviationHpa: _double(map['pressureDeviationHpa']),
      pressureDeviationPercent: _double(map['pressureDeviationPercent']),
      densityDeviationKgM3: _double(map['densityDeviationKgM3']),
      densityDeviationPercent: _double(map['densityDeviationPercent']),
      saturationVaporPressureHpa: _double(map['saturationVaporPressureHpa']),
      vaporPressureHpa: _double(map['vaporPressureHpa']),
      dryAirPartialPressureHpa: _double(map['dryAirPartialPressureHpa']),
      humidAirDensityKgM3: _double(map['humidAirDensityKgM3']),
      densityAltitudeM: _double(map['densityAltitudeM']),
      densityAltitudeDifferenceM: _double(map['densityAltitudeDifferenceM']),
      atmosphereStatus: _string(map['atmosphereStatus']),
      isAtmosphereWithinSupportedLimits: _bool(
        map['isAtmosphereWithinSupportedLimits'],
      ),
      windSpeedKmh: _double(map['windSpeedKmh']),
      windSpeedMs: _double(map['windSpeedMs']),
      windDirection: _string(map['windDirection']),
      headwindComponentMs: _double(map['headwindComponentMs']),
      tailwindComponentMs: _double(map['tailwindComponentMs']),
      crosswindComponentMs: _double(map['crosswindComponentMs']),
      crosswindDirection: _string(map['crosswindDirection']),
      commandedAirspeedMs: _double(map['commandedAirspeedMs']),
      effectiveAirspeedMs: _double(map['effectiveAirspeedMs']),
      estimatedGroundSpeedMs: _double(map['estimatedGroundSpeedMs']),
      windIntensityStatus: _string(map['windIntensityStatus']),
      windSafetyStatus: _string(map['windSafetyStatus']),
      isWindWithinSupportedLimits: _bool(map['isWindWithinSupportedLimits']),
      usesComponentDatabase: _bool(map['usesComponentDatabase']),
      hasRealMotorPropellerData: _bool(map['hasRealMotorPropellerData']),
      motorComponentId: _nullableString(map['motorComponentId']),
      propellerComponentId: _nullableString(map['propellerComponentId']),
      motorPropellerCombinationId: _nullableString(
        map['motorPropellerCombinationId'],
      ),
      componentDataSource: _string(map['componentDataSource']),
      componentTestConditions: _string(map['componentTestConditions']),
      realTestMaximumThrustPerMotorN: _double(
        map['realTestMaximumThrustPerMotorN'],
      ),
      realTestTotalMaximumThrustN: _double(map['realTestTotalMaximumThrustN']),
      realTestMaximumCurrentPerMotorA: _double(
        map['realTestMaximumCurrentPerMotorA'],
      ),
      realTestTotalMaximumCurrentA: _double(
        map['realTestTotalMaximumCurrentA'],
      ),
      realTestMaximumPowerPerMotorW: _double(
        map['realTestMaximumPowerPerMotorW'],
      ),
      realTestTotalMaximumPowerW: _double(map['realTestTotalMaximumPowerW']),
      realTestVoltageV: _double(map['realTestVoltageV']),
      realTestThrustToWeight: _double(map['realTestThrustToWeight']),
      componentCompatibilityScore: _int(map['componentCompatibilityScore']),
      componentCompatibilityStatus: _string(
        map['componentCompatibilityStatus'],
      ),
      componentCompatibilityMessage: _string(
        map['componentCompatibilityMessage'],
      ),
      isComponentSelectionCompatible: _bool(
        map['isComponentSelectionCompatible'],
      ),
      climbPerformance: ClimbPerformanceResult.fromMap(
        _objectMap(map['climbPerformance']),
      ),
      enduranceRange: EnduranceRangeResult.fromMap(
        _objectMap(map['enduranceRange']),
      ),
      glidePerformance: GlidePerformanceResult.fromMap(
        _objectMap(map['glidePerformance']),
      ),
      stability: StabilityResult.fromMap(_objectMap(map['stability'])),
      flightEnvelope: FlightEnvelopeResult.fromMap(
        _objectMap(map['flightEnvelope']),
      ),
      wingLoadingStatus: _string(map['wingLoadingStatus']),
      powerToWeightStatus: _string(map['powerToWeightStatus']),
      thrustToWeightStatus: _string(map['thrustToWeightStatus']),
      aerodynamicScore: _nullableInt(map['aerodynamicScore']),
      propulsionScore: _int(map['propulsionScore']),
      energyScore: _int(map['energyScore']),
      overallScore: _int(map['overallScore']),
      riskScore: _int(map['riskScore']),
      status: _string(map['status']),
      recommendation: _string(map['recommendation']),
    );
  }

  String _encode(Map<String, dynamic> value) {
    return jsonEncode(_prepareForJson(value));
  }

  Object? _prepareForJson(Object? value) {
    if (value is double && !value.isFinite) {
      if (value.isNaN) {
        return const {'__aerolabNumber__': 'nan'};
      }

      if (value.isNegative) {
        return const {'__aerolabNumber__': 'negativeInfinity'};
      }

      return const {'__aerolabNumber__': 'positiveInfinity'};
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _prepareForJson(item)),
      );
    }

    if (value is Iterable) {
      return value.map(_prepareForJson).toList();
    }

    return value;
  }

  Map<String, dynamic> _decode(String source) {
    final decoded = _restoreSpecialNumbers(jsonDecode(source));

    if (decoded is! Map) {
      throw const FormatException(
        'Analiz geçmişi snapshot verisi nesne değil.',
      );
    }

    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  Object? _restoreSpecialNumbers(Object? value) {
    if (value is Map) {
      if (value.length == 1 && value['__aerolabNumber__'] is String) {
        return switch (value['__aerolabNumber__']) {
          'nan' => double.nan,
          'positiveInfinity' => double.infinity,
          'negativeInfinity' => double.negativeInfinity,
          _ => throw const FormatException(
            'Bilinmeyen özel sayısal snapshot değeri.',
          ),
        };
      }

      return value.map(
        (key, item) => MapEntry(key.toString(), _restoreSpecialNumbers(item)),
      );
    }

    if (value is List) {
      return value.map(_restoreSpecialNumbers).toList();
    }

    return value;
  }

  static Map<String, dynamic> _dynamicMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('Beklenen nesne verisi bulunamadı.');
    }
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static Map<String, Object?> _objectMap(Object? value) {
    return _dynamicMap(value).cast<String, Object?>();
  }

  static List<Object?> _list(Object? value) {
    if (value is! List) {
      throw const FormatException('Beklenen liste verisi bulunamadı.');
    }
    return value.cast<Object?>();
  }

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    throw FormatException('Double değer okunamadı: $value');
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Int değer okunamadı: $value');
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    return _int(value);
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    throw FormatException('Bool değer okunamadı: $value');
  }

  static String _string(Object? value) {
    if (value is String) return value;
    throw FormatException('String değer okunamadı: $value');
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    return _string(value);
  }
}
