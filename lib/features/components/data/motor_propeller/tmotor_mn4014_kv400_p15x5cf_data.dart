import '../../models/motor_propeller_combination.dart';

class TMotorMn4014Kv400P15x5CfData {
  static const String combinationId = 'tmotor-mn4014-kv400-p15x5cf-6s';

  static const String motorComponentId = 'tmotor-mn4014-kv400';

  static const String propellerComponentId = 'tmotor-p15x5-cf';

  static MotorPropellerCombination create() {
    return MotorPropellerCombination(
      id: combinationId,
      motorComponentId: motorComponentId,
      propellerComponentId: propellerComponentId,
      dataSource: 'T-MOTOR official MN4014 KV400 manufacturer test table',
      testDate: '2026-07-18',
      testConditions:
          'T-MOTOR 15x5 CF propeller and 22.2 V test voltage. '
          'Manufacturer publication date not specified; testDate '
          'records the source access date.',
      performancePoints: [
        MotorPropellerPerformancePoint(
          voltageV: 22.2,
          throttlePercent: 50,
          currentA: 5.7,
          electricalPowerW: 126.54,
          thrustN: 12.258313,
          rpm: 4500,
          efficiencyGramPerWatt: 9.88,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 22.2,
          throttlePercent: 65,
          currentA: 9.1,
          electricalPowerW: 202.02,
          thrustN: 15.984839,
          rpm: 5200,
          efficiencyGramPerWatt: 8.07,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 22.2,
          throttlePercent: 75,
          currentA: 12.0,
          electricalPowerW: 266.40,
          thrustN: 19.122968,
          rpm: 5800,
          efficiencyGramPerWatt: 7.32,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 22.2,
          throttlePercent: 85,
          currentA: 15.8,
          electricalPowerW: 350.76,
          thrustN: 23.241761,
          rpm: 6400,
          efficiencyGramPerWatt: 6.76,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 22.2,
          throttlePercent: 100,
          currentA: 18.7,
          electricalPowerW: 415.14,
          thrustN: 25.693423,
          rpm: 6700,
          efficiencyGramPerWatt: 6.31,
        ),
      ],
      notes:
          'Thrust values were published in gram-force and converted '
          'to newtons using 1 gf = 0.00980665 N. Voltage, current, '
          'power, thrust, RPM, throttle and efficiency values preserve '
          'the official manufacturer table.',
    );
  }
}
