import '../../models/motor_propeller_combination.dart';

class TMotorMn3510Kv360P15x5CfData {
  static const String combinationId = 'tmotor-mn3510-kv360-p15x5cf-4s';

  static const String motorComponentId = 'tmotor-mn3510-kv360';

  static const String propellerComponentId = 'tmotor-p15x5-cf';

  static MotorPropellerCombination create() {
    return MotorPropellerCombination(
      id: combinationId,
      motorComponentId: motorComponentId,
      propellerComponentId: propellerComponentId,
      dataSource: 'T-MOTOR official MN3510 KV360 manufacturer test table',
      testDate: '2026-07-18',
      testConditions:
          'T-MOTOR 15x5 CF propeller, 14.8 V test voltage. '
          'Manufacturer table reports 42 °C motor surface temperature '
          'after 10 minutes at 100% throttle.',
      performancePoints: [
        MotorPropellerPerformancePoint(
          voltageV: 14.8,
          throttlePercent: 50,
          currentA: 1.5,
          electricalPowerW: 22.20,
          thrustN: 3.334261,
          rpm: 2600,
          efficiencyGramPerWatt: 15.32,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 14.8,
          throttlePercent: 65,
          currentA: 3.0,
          electricalPowerW: 44.40,
          thrustN: 5.687857,
          rpm: 3300,
          efficiencyGramPerWatt: 13.06,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 14.8,
          throttlePercent: 75,
          currentA: 4.5,
          electricalPowerW: 66.60,
          thrustN: 7.453054,
          rpm: 3800,
          efficiencyGramPerWatt: 11.41,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 14.8,
          throttlePercent: 85,
          currentA: 5.8,
          electricalPowerW: 85.84,
          thrustN: 8.825985,
          rpm: 4100,
          efficiencyGramPerWatt: 10.48,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 14.8,
          throttlePercent: 100,
          currentA: 6.8,
          electricalPowerW: 100.64,
          thrustN: 9.806650,
          rpm: 4400,
          efficiencyGramPerWatt: 9.94,
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
