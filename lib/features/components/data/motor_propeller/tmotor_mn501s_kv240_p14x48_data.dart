import '../../models/motor_propeller_combination.dart';

class TMotorMn501sKv240P14x48Data {
  static const String combinationId = 'tmotor-mn501s-kv240-p14x48-12s';

  static const String motorComponentId = 'tmotor-mn501s-kv240';

  static const String propellerComponentId = 'tmotor-p14x48';

  static MotorPropellerCombination create() {
    return MotorPropellerCombination(
      id: combinationId,
      motorComponentId: motorComponentId,
      propellerComponentId: propellerComponentId,
      dataSource: 'T-MOTOR official MN501-S KV240 manufacturer test table',
      testDate: '2026-07-18',
      testConditions:
          'P14x4.8 propeller, approximately 48.5 V, '
          'ambient temperature 9.2 °C. Manufacturer publication date '
          'not specified; testDate records the source access date.',
      performancePoints: [
        MotorPropellerPerformancePoint(
          voltageV: 48.50,
          throttlePercent: 40,
          currentA: 2.90,
          electricalPowerW: 141,
          thrustN: 9.561484,
          rpm: 5011,
          efficiencyGramPerWatt: 6.93,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.49,
          throttlePercent: 42,
          currentA: 3.12,
          electricalPowerW: 151,
          thrustN: 10.061623,
          rpm: 5182,
          efficiencyGramPerWatt: 6.79,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.50,
          throttlePercent: 44,
          currentA: 3.36,
          electricalPowerW: 163,
          thrustN: 10.630409,
          rpm: 5337,
          efficiencyGramPerWatt: 6.65,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.49,
          throttlePercent: 46,
          currentA: 3.62,
          electricalPowerW: 176,
          thrustN: 11.199194,
          rpm: 5508,
          efficiencyGramPerWatt: 6.50,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.49,
          throttlePercent: 48,
          currentA: 3.90,
          electricalPowerW: 189,
          thrustN: 11.915080,
          rpm: 5667,
          efficiencyGramPerWatt: 6.42,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.53,
          throttlePercent: 50,
          currentA: 4.20,
          electricalPowerW: 204,
          thrustN: 12.572125,
          rpm: 5834,
          efficiencyGramPerWatt: 6.30,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.53,
          throttlePercent: 52,
          currentA: 4.59,
          electricalPowerW: 223,
          thrustN: 13.592017,
          rpm: 6035,
          efficiencyGramPerWatt: 6.22,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.53,
          throttlePercent: 54,
          currentA: 4.97,
          electricalPowerW: 241,
          thrustN: 14.582489,
          rpm: 6213,
          efficiencyGramPerWatt: 6.16,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 56,
          currentA: 5.33,
          electricalPowerW: 259,
          thrustN: 15.367021,
          rpm: 6383,
          efficiencyGramPerWatt: 6.06,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.53,
          throttlePercent: 58,
          currentA: 5.65,
          electricalPowerW: 274,
          thrustN: 16.141746,
          rpm: 6413,
          efficiencyGramPerWatt: 6.00,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 60,
          currentA: 5.99,
          electricalPowerW: 290,
          thrustN: 16.965504,
          rpm: 6655,
          efficiencyGramPerWatt: 5.96,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 62,
          currentA: 6.35,
          electricalPowerW: 308,
          thrustN: 17.740230,
          rpm: 6829,
          efficiencyGramPerWatt: 5.87,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 64,
          currentA: 6.79,
          electricalPowerW: 329,
          thrustN: 18.681668,
          rpm: 6993,
          efficiencyGramPerWatt: 5.78,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 66,
          currentA: 7.25,
          electricalPowerW: 352,
          thrustN: 19.417167,
          rpm: 7161,
          efficiencyGramPerWatt: 5.63,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.56,
          throttlePercent: 68,
          currentA: 7.78,
          electricalPowerW: 378,
          thrustN: 20.623385,
          rpm: 7340,
          efficiencyGramPerWatt: 5.57,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.55,
          throttlePercent: 70,
          currentA: 8.35,
          electricalPowerW: 405,
          thrustN: 21.613857,
          rpm: 7534,
          efficiencyGramPerWatt: 5.44,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.55,
          throttlePercent: 75,
          currentA: 9.72,
          electricalPowerW: 472,
          thrustN: 24.330299,
          rpm: 7947,
          efficiencyGramPerWatt: 5.26,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.54,
          throttlePercent: 80,
          currentA: 11.35,
          electricalPowerW: 551,
          thrustN: 27.331134,
          rpm: 8376,
          efficiencyGramPerWatt: 5.06,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.53,
          throttlePercent: 90,
          currentA: 14.74,
          electricalPowerW: 715,
          thrustN: 32.499238,
          rpm: 9161,
          efficiencyGramPerWatt: 4.63,
        ),
        MotorPropellerPerformancePoint(
          voltageV: 48.52,
          throttlePercent: 100,
          currentA: 18.52,
          electricalPowerW: 899,
          thrustN: 38.157675,
          rpm: 9870,
          efficiencyGramPerWatt: 4.33,
        ),
      ],
      notes:
          'Thrust values were published in gram-force and converted '
          'to newtons using 1 gf = 0.00980665 N. Voltage, current, '
          'power, RPM, throttle and efficiency values preserve the '
          'manufacturer table.',
    );
  }
}
