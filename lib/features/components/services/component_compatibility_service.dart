import '../models/battery_component.dart';
import '../models/component_compatibility_result.dart';
import '../models/esc_component.dart';
import '../models/motor_component.dart';
import '../models/motor_propeller_combination.dart';
import '../models/propeller_component.dart';

class ComponentCompatibilityService {
  const ComponentCompatibilityService();

  ComponentCompatibilityResult evaluate({
    required MotorComponent motor,
    required PropellerComponent propeller,
    required BatteryComponent battery,
    required EscComponent esc,
    MotorPropellerCombination? combination,
  }) {
    final issues = <CompatibilityIssue>[];

    _checkMotorBatteryCompatibility(
      motor: motor,
      battery: battery,
      issues: issues,
    );

    _checkMotorPropellerCompatibility(
      motor: motor,
      propeller: propeller,
      battery: battery,
      issues: issues,
    );

    _checkEscCompatibility(
      motor: motor,
      battery: battery,
      esc: esc,
      combination: combination,
      issues: issues,
    );

    _checkCombinationCompatibility(
      motor: motor,
      propeller: propeller,
      battery: battery,
      combination: combination,
      issues: issues,
    );

    final criticalIssueCount = issues
        .where((issue) => issue.severity == CompatibilitySeverity.critical)
        .length;

    final warningIssueCount = issues
        .where((issue) => issue.severity == CompatibilitySeverity.warning)
        .length;

    final infoIssueCount = issues
        .where((issue) => issue.severity == CompatibilitySeverity.info)
        .length;

    final score = _calculateScore(
      criticalIssueCount: criticalIssueCount,
      warningIssueCount: warningIssueCount,
      infoIssueCount: infoIssueCount,
    );

    return ComponentCompatibilityResult(
      isCompatible: criticalIssueCount == 0,
      score: score,
      issues: issues,
    );
  }

  void _checkMotorBatteryCompatibility({
    required MotorComponent motor,
    required BatteryComponent battery,
    required List<CompatibilityIssue> issues,
  }) {
    if (!motor.supportsVoltage(battery.nominalVoltageV)) {
      issues.add(
        CompatibilityIssue(
          code: 'motor_battery_voltage_mismatch',
          title: 'Motor–batarya voltaj uyumsuzluğu',
          message:
              '${battery.nominalVoltageV.toStringAsFixed(1)} V batarya, '
              '${motor.minimumVoltageV.toStringAsFixed(1)}–'
              '${motor.maximumVoltageV.toStringAsFixed(1)} V motor '
              'aralığının dışındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!motor.supportsCellCount(battery.cellCount)) {
      issues.add(
        CompatibilityIssue(
          code: 'motor_battery_cell_mismatch',
          title: 'Motor–hücre sayısı uyumsuzluğu',
          message:
              '${battery.cellCount}S batarya, motorun önerilen '
              '${motor.minimumRecommendedCellCount}S–'
              '${motor.maximumRecommendedCellCount}S aralığının dışındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!battery.supportsContinuousCurrent(motor.continuousCurrentA)) {
      issues.add(
        CompatibilityIssue(
          code: 'battery_continuous_current_insufficient',
          title: 'Batarya sürekli akımı yetersiz',
          message:
              'Bataryanın sürekli akım kapasitesi '
              '${battery.maximumContinuousCurrentA.toStringAsFixed(1)} A, '
              'motorun ${motor.continuousCurrentA.toStringAsFixed(1)} A '
              'sürekli akım gereksinimini karşılamıyor.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!battery.supportsBurstCurrent(motor.maximumCurrentA)) {
      issues.add(
        CompatibilityIssue(
          code: 'battery_burst_current_insufficient',
          title: 'Batarya burst akımı yetersiz',
          message:
              'Bataryanın burst akım kapasitesi '
              '${battery.maximumBurstCurrentA.toStringAsFixed(1)} A, '
              'motorun ${motor.maximumCurrentA.toStringAsFixed(1)} A '
              'maksimum akım gereksinimini karşılamıyor.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }
  }

  void _checkMotorPropellerCompatibility({
    required MotorComponent motor,
    required PropellerComponent propeller,
    required BatteryComponent battery,
    required List<CompatibilityIssue> issues,
  }) {
    if (!motor.supportsPropellerDiameter(propeller.diameterInch)) {
      issues.add(
        CompatibilityIssue(
          code: 'motor_propeller_diameter_mismatch',
          title: 'Pervane çapı motorla uyumsuz',
          message:
              '${propeller.diameterInch.toStringAsFixed(1)} inç pervane, '
              'motorun önerilen '
              '${motor.minimumRecommendedPropellerDiameterInch.toStringAsFixed(1)}–'
              '${motor.maximumRecommendedPropellerDiameterInch.toStringAsFixed(1)} '
              'inç aralığının dışındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!propeller.supportsMotorKv(motor.kvRating)) {
      issues.add(
        CompatibilityIssue(
          code: 'propeller_motor_kv_mismatch',
          title: 'Pervane–motor KV uyumsuzluğu',
          message:
              '${motor.kvRating.toStringAsFixed(0)} KV motor, pervanenin '
              'önerilen ${propeller.minimumRecommendedKv.toStringAsFixed(0)}–'
              '${propeller.maximumRecommendedKv.toStringAsFixed(0)} KV '
              'aralığının dışındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!propeller.supportsVoltage(battery.nominalVoltageV)) {
      issues.add(
        CompatibilityIssue(
          code: 'propeller_battery_voltage_mismatch',
          title: 'Pervane–batarya voltaj uyumsuzluğu',
          message:
              '${battery.nominalVoltageV.toStringAsFixed(1)} V batarya, '
              'pervanenin önerilen '
              '${propeller.minimumRecommendedVoltageV.toStringAsFixed(1)}–'
              '${propeller.maximumRecommendedVoltageV.toStringAsFixed(1)} V '
              'aralığının dışındadır.',
          severity: CompatibilitySeverity.warning,
        ),
      );
    }
  }

  void _checkEscCompatibility({
    required MotorComponent motor,
    required BatteryComponent battery,
    required EscComponent esc,
    required MotorPropellerCombination? combination,
    required List<CompatibilityIssue> issues,
  }) {
    if (!esc.supportsCellCount(battery.cellCount)) {
      issues.add(
        CompatibilityIssue(
          code: 'esc_battery_cell_mismatch',
          title: 'ESC–batarya hücre uyumsuzluğu',
          message:
              '${battery.cellCount}S batarya, ESC’nin desteklediği '
              '${esc.minimumSupportedCellCount}S–'
              '${esc.maximumSupportedCellCount}S aralığının dışındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    final requiredContinuousCurrentA =
        combination?.maximumCurrentA ?? motor.continuousCurrentA;

    final requiredBurstCurrentA =
        combination?.maximumCurrentA ?? motor.maximumCurrentA;

    if (!esc.supportsContinuousCurrent(requiredContinuousCurrentA)) {
      issues.add(
        CompatibilityIssue(
          code: 'esc_continuous_current_insufficient',
          title: 'ESC sürekli akımı yetersiz',
          message:
              'ESC sürekli akım kapasitesi '
              '${esc.continuousCurrentA.toStringAsFixed(1)} A, gerekli '
              '${requiredContinuousCurrentA.toStringAsFixed(1)} A değerinin '
              'altındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (!esc.supportsBurstCurrent(requiredBurstCurrentA)) {
      issues.add(
        CompatibilityIssue(
          code: 'esc_burst_current_insufficient',
          title: 'ESC burst akımı yetersiz',
          message:
              'ESC burst akım kapasitesi '
              '${esc.burstCurrentA.toStringAsFixed(1)} A, gerekli '
              '${requiredBurstCurrentA.toStringAsFixed(1)} A değerinin '
              'altındadır.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    final escReservePercent =
        (esc.continuousCurrentA - requiredContinuousCurrentA) /
        requiredContinuousCurrentA *
        100;

    if (escReservePercent >= 0 && escReservePercent < 15) {
      issues.add(
        CompatibilityIssue(
          code: 'esc_current_margin_low',
          title: 'ESC akım rezervi düşük',
          message:
              'ESC sürekli akım rezervi yalnızca '
              '%${escReservePercent.toStringAsFixed(1)}. En az %15–20 '
              'mühendislik rezervi önerilir.',
          severity: CompatibilitySeverity.warning,
        ),
      );
    }
  }

  void _checkCombinationCompatibility({
    required MotorComponent motor,
    required PropellerComponent propeller,
    required BatteryComponent battery,
    required MotorPropellerCombination? combination,
    required List<CompatibilityIssue> issues,
  }) {
    if (combination == null) {
      issues.add(
        const CompatibilityIssue(
          code: 'real_test_table_not_selected',
          title: 'Gerçek test tablosu seçilmedi',
          message:
              'Uyumluluk kontrolü üretici performans tablosu olmadan '
              'teknik katalog değerleri üzerinden yapılmıştır.',
          severity: CompatibilitySeverity.info,
        ),
      );
      return;
    }

    if (combination.motorComponentId != motor.id) {
      issues.add(
        CompatibilityIssue(
          code: 'combination_motor_mismatch',
          title: 'Test tablosu motorla eşleşmiyor',
          message:
              'Seçilen test tablosu ${combination.motorComponentId} motoruna '
              'aittir; mevcut motor ${motor.id}.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    if (combination.propellerComponentId != propeller.id) {
      issues.add(
        CompatibilityIssue(
          code: 'combination_propeller_mismatch',
          title: 'Test tablosu pervaneyle eşleşmiyor',
          message:
              'Seçilen test tablosu ${combination.propellerComponentId} '
              'pervanesine aittir; mevcut pervane ${propeller.id}.',
          severity: CompatibilitySeverity.critical,
        ),
      );
    }

    final hasCompatibleVoltage = combination.performancePoints.any(
      (point) => (point.voltageV - battery.nominalVoltageV).abs() <= 0.5,
    );

    if (!hasCompatibleVoltage) {
      final testedVoltages = combination.performancePoints
          .map((point) => point.voltageV.toStringAsFixed(1))
          .toSet()
          .join(', ');

      issues.add(
        CompatibilityIssue(
          code: 'combination_voltage_mismatch',
          title: 'Test tablosu voltajı bataryayla eşleşmiyor',
          message:
              'Batarya ${battery.nominalVoltageV.toStringAsFixed(1)} V, '
              'test tablosundaki voltaj değerleri ise $testedVoltages V.',
          severity: CompatibilitySeverity.warning,
        ),
      );
    }
  }

  int _calculateScore({
    required int criticalIssueCount,
    required int warningIssueCount,
    required int infoIssueCount,
  }) {
    final rawScore =
        100 -
        (criticalIssueCount * 30) -
        (warningIssueCount * 10) -
        (infoIssueCount * 2);

    return rawScore.clamp(0, 100);
  }
}
