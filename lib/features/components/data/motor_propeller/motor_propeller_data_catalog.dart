import '../../models/motor_propeller_combination.dart';
import 'tmotor_mn3510_kv360_p15x5cf_data.dart';
import 'tmotor_mn4014_kv400_p15x5cf_data.dart';
import 'tmotor_mn501s_kv240_p14x48_data.dart';

class MotorPropellerDataCatalog {
  MotorPropellerDataCatalog._();

  static List<MotorPropellerCombination> createAll() {
    return List<MotorPropellerCombination>.unmodifiable([
      TMotorMn501sKv240P14x48Data.create(),
      TMotorMn3510Kv360P15x5CfData.create(),
      TMotorMn4014Kv400P15x5CfData.create(),
    ]);
  }

  static int get combinationCount => createAll().length;

  static int get performancePointCount {
    return createAll().fold<int>(
      0,
      (total, combination) => total + combination.performancePoints.length,
    );
  }

  static MotorPropellerCombination? findById(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final combination in createAll()) {
      if (combination.id == normalizedId) {
        return combination;
      }
    }

    return null;
  }

  static List<MotorPropellerCombination> findByMotorId(
    String motorComponentId,
  ) {
    final normalizedMotorId = motorComponentId.trim();

    if (normalizedMotorId.isEmpty) {
      return const [];
    }

    return List<MotorPropellerCombination>.unmodifiable(
      createAll().where(
        (combination) => combination.motorComponentId == normalizedMotorId,
      ),
    );
  }

  static List<MotorPropellerCombination> findByPropellerId(
    String propellerComponentId,
  ) {
    final normalizedPropellerId = propellerComponentId.trim();

    if (normalizedPropellerId.isEmpty) {
      return const [];
    }

    return List<MotorPropellerCombination>.unmodifiable(
      createAll().where(
        (combination) =>
            combination.propellerComponentId == normalizedPropellerId,
      ),
    );
  }
}
