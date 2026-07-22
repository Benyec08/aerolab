import 'dart:convert';

import 'package:flutter/material.dart';

import '../analysis/services/battery_chemistry_service.dart';
import '../analysis/services/battery_validation_service.dart';
import '../components/data/motor_propeller/motor_propeller_data_catalog.dart';
import '../components/models/motor_propeller_combination.dart';

class AircraftFormDialog extends StatefulWidget {
  final Map<String, dynamic>? aircraft;

  const AircraftFormDialog({super.key, this.aircraft});

  bool get isEditing => aircraft != null;

  @override
  State<AircraftFormDialog> createState() => _AircraftFormDialogState();
}

class _AircraftFormDialogState extends State<AircraftFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BatteryValidationService _batteryValidationService =
      BatteryValidationService();
  final BatteryChemistryService _batteryChemistryService =
      BatteryChemistryService();

  // Genel bilgiler
  late final TextEditingController _nameController;

  // Fiziksel özellikler
  late final TextEditingController _weightController;
  late final TextEditingController _wingAreaController;
  late final TextEditingController _wingSpanController;
  late final TextEditingController _cruiseSpeedController;
  late final TextEditingController _zeroLiftDragCoefficientController;
  late final TextEditingController _maxLiftCoefficientController;
  late final TextEditingController _oswaldEfficiencyController;

  // Motor sistemi
  late final TextEditingController _motorCountController;
  late final TextEditingController _motorPowerController;
  late final TextEditingController _escEfficiencyController;
  late final TextEditingController _motorEfficiencyController;
  late final TextEditingController _continuousMotorPowerController;
  late final TextEditingController _maximumMotorPowerController;

  // Batarya sistemi
  late final TextEditingController _batteryController;
  late final TextEditingController _batteryVoltageController;
  late final TextEditingController _batteryCapacityController;
  late final TextEditingController _batteryCellController;
  late final TextEditingController _cellInternalResistanceController;

  // Pervane sistemi
  late final TextEditingController _propellerDiameterController;

  // Sprint 15E — CG ve statik marj
  late final TextEditingController _meanAerodynamicChordController;
  late final TextEditingController _macLeadingEdgeController;
  late final TextEditingController _neutralPointPercentController;
  late final TextEditingController _minimumCgPercentController;
  late final TextEditingController _maximumCgPercentController;

  // Sprint 15F — Uçuş zarfı girdileri
  late final TextEditingController _maximumOperatingSpeedController;
  late final TextEditingController _positiveLimitLoadFactorController;
  late final TextEditingController _negativeLimitLoadFactorController;

  late final TextEditingController _motorMassController;
  late final TextEditingController _motorArmController;
  late final TextEditingController _batteryMassController;
  late final TextEditingController _batteryArmController;
  late final TextEditingController _airframeMassController;
  late final TextEditingController _airframeArmController;
  late final TextEditingController _payloadMassController;
  late final TextEditingController _payloadArmController;

  late String _selectedType;
  late String _selectedBatteryType;
  String? _selectedMotorPropellerCombinationId;

  late final List<MotorPropellerCombination> _motorPropellerCombinations;

  final List<String> _aircraftTypes = const [
    'Sabit Kanat',
    'Drone',
    'VTOL',
    'Helikopter',
  ];

  final List<String> _batteryTypes = const ['LiPo', 'Li-Ion', 'LiHV'];

  @override
  void initState() {
    super.initState();

    final aircraft = widget.aircraft;

    _motorPropellerCombinations = MotorPropellerDataCatalog.createAll();

    final existingCombinationId = aircraft?['motorPropellerCombinationId']
        ?.toString();

    _selectedMotorPropellerCombinationId =
        _containsMotorPropellerCombination(existingCombinationId)
        ? existingCombinationId
        : null;

    final existingType = aircraft?['type']?.toString();
    _selectedType = _aircraftTypes.contains(existingType)
        ? existingType!
        : 'Sabit Kanat';

    final existingBatteryType = aircraft?['batteryType']?.toString();
    _selectedBatteryType = _batteryTypes.contains(existingBatteryType)
        ? existingBatteryType!
        : 'LiPo';

    _nameController = TextEditingController(
      text: aircraft?['name']?.toString() ?? '',
    );

    _weightController = TextEditingController(
      text: aircraft?['weight']?.toString() ?? '',
    );

    _wingAreaController = TextEditingController(
      text: aircraft?['wingArea']?.toString() ?? '',
    );

    _wingSpanController = TextEditingController(
      text: aircraft?['wingSpan']?.toString() ?? '',
    );

    _cruiseSpeedController = TextEditingController(
      text: aircraft?['cruiseSpeedMs']?.toString() ?? '15',
    );
    _zeroLiftDragCoefficientController = TextEditingController(
      text: aircraft?['zeroLiftDragCoefficient']?.toString() ?? '0.030',
    );
    _maxLiftCoefficientController = TextEditingController(
      text: aircraft?['maxLiftCoefficient']?.toString() ?? '1.4',
    );
    _oswaldEfficiencyController = TextEditingController(
      text: _efficiencyAsPercent(
        aircraft?['oswaldEfficiencyFactor'],
        fallback: 0.80,
      ),
    );

    _motorCountController = TextEditingController(
      text: aircraft?['motorCount']?.toString() ?? '1',
    );

    _motorPowerController = TextEditingController(
      text: aircraft?['motorPower']?.toString() ?? '',
    );

    _escEfficiencyController = TextEditingController(
      text: _efficiencyAsPercent(aircraft?['escEfficiency'], fallback: 0.95),
    );

    _motorEfficiencyController = TextEditingController(
      text: _efficiencyAsPercent(aircraft?['motorEfficiency'], fallback: 0.85),
    );

    final existingMotorPower = aircraft?['motorPower']?.toString() ?? '';

    _continuousMotorPowerController = TextEditingController(
      text:
          aircraft?['continuousMotorPowerW']?.toString() ?? existingMotorPower,
    );

    _maximumMotorPowerController = TextEditingController(
      text: aircraft?['maximumMotorPowerW']?.toString() ?? existingMotorPower,
    );

    _batteryController = TextEditingController(
      text: aircraft?['battery']?.toString() ?? '',
    );

    _batteryVoltageController = TextEditingController(
      text: aircraft?['batteryVoltage']?.toString() ?? '',
    );

    _batteryCapacityController = TextEditingController(
      text: aircraft?['batteryCapacity']?.toString() ?? '',
    );

    _batteryCellController = TextEditingController(
      text: aircraft?['batteryCellCount']?.toString() ?? '',
    );

    final storedInternalResistance = _toOptionalPositiveDouble(
      aircraft?['cellInternalResistanceMilliOhm'],
    );

    _cellInternalResistanceController = TextEditingController(
      text:
          storedInternalResistance?.toString() ??
          _defaultCellInternalResistanceMilliOhm(
            _selectedBatteryType,
          ).toString(),
    );

    _propellerDiameterController = TextEditingController(
      text: aircraft?['propellerDiameter']?.toString() ?? '',
    );

    final storedMassStations = _decodeMassStations(
      aircraft?['massStationsJson'],
    );

    Map<String, dynamic>? findStation(String name) {
      for (final station in storedMassStations) {
        if (station['name']?.toString() == name) {
          return station;
        }
      }
      return null;
    }

    final motorStation = findStation('Motor Sistemi');
    final batteryStation = findStation('Batarya');
    final airframeStation = findStation('Gövde');
    final payloadStation = findStation('Faydalı Yük');

    _meanAerodynamicChordController = TextEditingController(
      text: aircraft?['meanAerodynamicChordM']?.toString() ?? '0.30',
    );
    _macLeadingEdgeController = TextEditingController(
      text: aircraft?['macLeadingEdgeFromDatumM']?.toString() ?? '0.40',
    );
    _neutralPointPercentController = TextEditingController(
      text: aircraft?['neutralPointPercentMac']?.toString() ?? '40',
    );
    _minimumCgPercentController = TextEditingController(
      text: aircraft?['minimumCgPercentMac']?.toString() ?? '20',
    );
    _maximumCgPercentController = TextEditingController(
      text: aircraft?['maximumCgPercentMac']?.toString() ?? '35',
    );

    _maximumOperatingSpeedController = TextEditingController(
      text: aircraft?['maximumOperatingSpeedMs']?.toString() ?? '25',
    );
    _positiveLimitLoadFactorController = TextEditingController(
      text: aircraft?['positiveLimitLoadFactor']?.toString() ?? '3.8',
    );
    _negativeLimitLoadFactorController = TextEditingController(
      text: aircraft?['negativeLimitLoadFactor']?.toString() ?? '-1.5',
    );

    _motorMassController = TextEditingController(
      text: motorStation?['massKg']?.toString() ?? '0.60',
    );
    _motorArmController = TextEditingController(
      text: motorStation?['armFromDatumM']?.toString() ?? '0.30',
    );
    _batteryMassController = TextEditingController(
      text: batteryStation?['massKg']?.toString() ?? '0.70',
    );
    _batteryArmController = TextEditingController(
      text: batteryStation?['armFromDatumM']?.toString() ?? '0.48',
    );
    _airframeMassController = TextEditingController(
      text: airframeStation?['massKg']?.toString() ?? '0.90',
    );
    _airframeArmController = TextEditingController(
      text: airframeStation?['armFromDatumM']?.toString() ?? '0.50',
    );
    _payloadMassController = TextEditingController(
      text: payloadStation?['massKg']?.toString() ?? '0.20',
    );
    _payloadArmController = TextEditingController(
      text: payloadStation?['armFromDatumM']?.toString() ?? '0.55',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _wingAreaController.dispose();
    _wingSpanController.dispose();
    _cruiseSpeedController.dispose();
    _zeroLiftDragCoefficientController.dispose();
    _maxLiftCoefficientController.dispose();
    _oswaldEfficiencyController.dispose();
    _motorCountController.dispose();
    _motorPowerController.dispose();
    _escEfficiencyController.dispose();
    _motorEfficiencyController.dispose();
    _continuousMotorPowerController.dispose();
    _maximumMotorPowerController.dispose();
    _batteryController.dispose();
    _batteryVoltageController.dispose();
    _batteryCapacityController.dispose();
    _batteryCellController.dispose();
    _cellInternalResistanceController.dispose();
    _propellerDiameterController.dispose();
    _meanAerodynamicChordController.dispose();
    _macLeadingEdgeController.dispose();
    _neutralPointPercentController.dispose();
    _minimumCgPercentController.dispose();
    _maximumCgPercentController.dispose();
    _maximumOperatingSpeedController.dispose();
    _positiveLimitLoadFactorController.dispose();
    _negativeLimitLoadFactorController.dispose();
    _motorMassController.dispose();
    _motorArmController.dispose();
    _batteryMassController.dispose();
    _batteryArmController.dispose();
    _airframeMassController.dispose();
    _airframeArmController.dispose();
    _payloadMassController.dispose();
    _payloadArmController.dispose();
    super.dispose();
  }

  String? _validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }

    return null;
  }

  String? _validatePositiveNumber(
    String? value,
    String fieldName, {
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }

    final normalizedValue = value.trim().replaceAll(',', '.');
    final number = double.tryParse(normalizedValue);

    if (number == null) {
      return 'Geçerli bir sayı giriniz.';
    }

    if (allowZero) {
      if (number < 0) {
        return '$fieldName negatif olamaz.';
      }
    } else if (number <= 0) {
      return '$fieldName sıfırdan büyük olmalıdır.';
    }

    return null;
  }

  String? _validateInteger(String? value, String fieldName) {
    final validation = _validatePositiveNumber(value, fieldName);

    if (validation != null) {
      return validation;
    }

    final parsedValue = double.tryParse(value!.trim().replaceAll(',', '.'));

    if (parsedValue == null || parsedValue != parsedValue.roundToDouble()) {
      return '$fieldName tam sayı olmalıdır.';
    }

    return null;
  }

  double? _toOptionalPositiveDouble(dynamic value) {
    final parsedValue = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString().replaceAll(',', '.') ?? '');

    if (parsedValue == null || parsedValue <= 0) {
      return null;
    }

    return parsedValue;
  }

  double _defaultCellInternalResistanceMilliOhm(String batteryType) {
    return _batteryChemistryService
        .getProfile(batteryType)
        .defaultCellInternalResistanceMilliOhm;
  }

  void _applyBatteryChemistryDefault(String batteryType) {
    _cellInternalResistanceController.text =
        _defaultCellInternalResistanceMilliOhm(batteryType).toString();
  }

  String _efficiencyAsPercent(dynamic value, {required double fallback}) {
    final parsedValue = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString().replaceAll(',', '.') ?? '');

    final efficiency = parsedValue ?? fallback;
    final percent = efficiency <= 1.0 ? efficiency * 100.0 : efficiency;

    return percent.toStringAsFixed(percent == percent.roundToDouble() ? 0 : 1);
  }

  String? _validateEfficiencyPercent(String? value, String fieldName) {
    final validation = _validatePositiveNumber(value, fieldName);

    if (validation != null) {
      return validation;
    }

    final number = double.tryParse(value!.trim().replaceAll(',', '.'));

    if (number == null || number <= 0 || number > 100) {
      return '$fieldName 0 ile 100 arasında olmalıdır.';
    }

    return null;
  }

  String? _validateMaximumMotorPower(String? value) {
    final validation = _validatePositiveNumber(value, 'Maksimum motor gücü');

    if (validation != null) {
      return validation;
    }

    final maximumPower = double.tryParse(value!.trim().replaceAll(',', '.'));
    final continuousPower = double.tryParse(
      _continuousMotorPowerController.text.trim().replaceAll(',', '.'),
    );

    if (maximumPower == null || continuousPower == null) {
      return null;
    }

    if (maximumPower < continuousPower) {
      return 'Maksimum güç, sürekli güçten küçük olamaz.';
    }

    return null;
  }

  String? _validateBatteryVoltage(String? value) {
    final numberValidation = _validatePositiveNumber(value, 'Batarya voltajı');

    if (numberValidation != null) {
      return numberValidation;
    }

    final cellCountAsDouble = double.tryParse(
      _batteryCellController.text.trim().replaceAll(',', '.'),
    );

    if (cellCountAsDouble == null ||
        cellCountAsDouble <= 0 ||
        cellCountAsDouble != cellCountAsDouble.roundToDouble()) {
      return 'Önce geçerli bir hücre sayısı giriniz.';
    }

    final enteredVoltage = double.tryParse(value!.trim().replaceAll(',', '.'));

    if (enteredVoltage == null) {
      return 'Geçerli bir voltaj giriniz.';
    }

    final cellCount = cellCountAsDouble.toInt();
    final isValid = _batteryValidationService.isVoltageValid(
      batteryType: _selectedBatteryType,
      cellCount: cellCount,
      enteredVoltage: enteredVoltage,
    );

    if (!isValid) {
      final expectedVoltage = _batteryValidationService.expectedVoltage(
        batteryType: _selectedBatteryType,
        cellCount: cellCount,
      );

      return '${cellCount}S $_selectedBatteryType için nominal voltaj '
          'yaklaşık ${expectedVoltage.toStringAsFixed(1)} V olmalıdır.';
    }

    return null;
  }

  double _parseDouble(TextEditingController controller) {
    return double.parse(controller.text.trim().replaceAll(',', '.'));
  }

  int _parseInt(TextEditingController controller) {
    return _parseDouble(controller).toInt();
  }

  double _parseEfficiency(TextEditingController controller) {
    return _parseDouble(controller) / 100.0;
  }

  List<Map<String, dynamic>> _decodeMassStations(dynamic value) {
    try {
      final decoded = value is String ? jsonDecode(value) : value;

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  List<Map<String, dynamic>> _buildMassStations() {
    final stations = <Map<String, dynamic>>[];

    void addStation({
      required String name,
      required TextEditingController massController,
      required TextEditingController armController,
    }) {
      final massKg = _parseDouble(massController);

      if (massKg <= 0.0) {
        return;
      }

      stations.add({
        'name': name,
        'massKg': massKg,
        'armFromDatumM': _parseDouble(armController),
      });
    }

    addStation(
      name: 'Motor Sistemi',
      massController: _motorMassController,
      armController: _motorArmController,
    );
    addStation(
      name: 'Batarya',
      massController: _batteryMassController,
      armController: _batteryArmController,
    );
    addStation(
      name: 'Gövde',
      massController: _airframeMassController,
      armController: _airframeArmController,
    );
    addStation(
      name: 'Faydalı Yük',
      massController: _payloadMassController,
      armController: _payloadArmController,
    );

    return stations;
  }

  bool _validateStabilityInputs() {
    if (_selectedType == 'Drone' || _selectedType == 'Helikopter') {
      return true;
    }

    final minimumCg = _parseDouble(_minimumCgPercentController);
    final maximumCg = _parseDouble(_maximumCgPercentController);

    if (minimumCg >= maximumCg) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Minimum CG limiti, maksimum CG limitinden küçük olmalıdır.',
          ),
        ),
      );
      return false;
    }

    final stations = _buildMassStations();
    final totalStationMass = stations.fold<double>(
      0.0,
      (sum, station) => sum + (station['massKg'] as double),
    );
    final aircraftMass = _parseDouble(_weightController);
    final allowedDifference = aircraftMass * 0.02;

    if ((totalStationMass - aircraftMass).abs() > allowedDifference) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kütle istasyonları toplamı '
            '${totalStationMass.toStringAsFixed(2)} kg, araç ağırlığı ise '
            '${aircraftMass.toStringAsFixed(2)} kg. Fark en fazla %2 olmalıdır.',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  bool _containsMotorPropellerCombination(String? combinationId) {
    if (combinationId == null || combinationId.trim().isEmpty) {
      return false;
    }

    return _motorPropellerCombinations.any(
      (combination) => combination.id == combinationId,
    );
  }

  MotorPropellerCombination? get _selectedMotorPropellerCombination {
    final selectedId = _selectedMotorPropellerCombinationId;

    if (selectedId == null) {
      return null;
    }

    for (final combination in _motorPropellerCombinations) {
      if (combination.id == selectedId) {
        return combination;
      }
    }

    return null;
  }

  String _combinationTitle(MotorPropellerCombination combination) {
    return '${combination.motorComponentId} + '
        '${combination.propellerComponentId}';
  }

  String _combinationSubtitle(MotorPropellerCombination combination) {
    return '${combination.performancePoints.length} test noktası • '
        'Maks. ${combination.maximumThrustN.toStringAsFixed(2)} N • '
        'Maks. ${combination.maximumElectricalPowerW.toStringAsFixed(0)} W';
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (!_validateStabilityInputs()) {
      return;
    }

    final batteryCellCount = _parseInt(_batteryCellController);
    final batterySummary = _batteryController.text.trim().isEmpty
        ? '${batteryCellCount}S $_selectedBatteryType'
        : _batteryController.text.trim();

    final selectedCombination = _selectedMotorPropellerCombination;

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'weight': _parseDouble(_weightController),
      'wingArea': _parseDouble(_wingAreaController),
      'wingSpan': _parseDouble(_wingSpanController),
      'cruiseSpeedMs': _parseDouble(_cruiseSpeedController),
      'zeroLiftDragCoefficient': _parseDouble(
        _zeroLiftDragCoefficientController,
      ),
      'maxLiftCoefficient': _parseDouble(_maxLiftCoefficientController),
      'oswaldEfficiencyFactor': _parseEfficiency(_oswaldEfficiencyController),
      'motorCount': _parseInt(_motorCountController),
      'motorPower': _parseDouble(_motorPowerController),
      'escEfficiency': _parseEfficiency(_escEfficiencyController),
      'motorEfficiency': _parseEfficiency(_motorEfficiencyController),
      'continuousMotorPowerW': _parseDouble(_continuousMotorPowerController),
      'maximumMotorPowerW': _parseDouble(_maximumMotorPowerController),
      'battery': batterySummary,
      'batteryType': _selectedBatteryType,
      'batteryVoltage': _parseDouble(_batteryVoltageController),
      'batteryCapacity': _parseDouble(_batteryCapacityController),
      'batteryCellCount': batteryCellCount,
      'cellInternalResistanceMilliOhm': _parseDouble(
        _cellInternalResistanceController,
      ),
      'propellerDiameter': _parseDouble(_propellerDiameterController),
      'motorComponentId': selectedCombination?.motorComponentId,
      'propellerComponentId': selectedCombination?.propellerComponentId,
      'motorPropellerCombinationId': selectedCombination?.id,
      'batteryComponentId': widget.aircraft?['batteryComponentId'],
      'escComponentId': widget.aircraft?['escComponentId'],
      'massStationsJson': jsonEncode(_buildMassStations()),
      'meanAerodynamicChordM': _parseDouble(_meanAerodynamicChordController),
      'macLeadingEdgeFromDatumM': _parseDouble(_macLeadingEdgeController),
      'neutralPointPercentMac': _parseDouble(_neutralPointPercentController),
      'minimumCgPercentMac': _parseDouble(_minimumCgPercentController),
      'maximumCgPercentMac': _parseDouble(_maximumCgPercentController),
      'maximumOperatingSpeedMs': _parseDouble(_maximumOperatingSpeedController),
      'positiveLimitLoadFactor': _parseDouble(
        _positiveLimitLoadFactorController,
      ),
      'negativeLimitLoadFactor': _parseDouble(
        _negativeLimitLoadFactorController,
      ),
      'created': widget.aircraft?['created'] as DateTime? ?? DateTime.now(),
    };

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        icon: Icons.flight_takeoff,
                        title: 'Araç Bilgileri',
                      ),
                      const SizedBox(height: 16),
                      _buildGeneralInformation(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.straighten,
                        title: 'Fiziksel Özellikler',
                      ),
                      const SizedBox(height: 16),
                      _buildPhysicalProperties(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.air_outlined,
                        title: 'Aerodinamik Performans',
                      ),
                      const SizedBox(height: 16),
                      _buildAerodynamicPerformance(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.balance_outlined,
                        title: 'Ağırlık Merkezi ve Statik Marj',
                      ),
                      const SizedBox(height: 16),
                      _buildStabilitySystem(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.show_chart_outlined,
                        title: 'Uçuş Zarfı',
                      ),
                      const SizedBox(height: 16),
                      _buildFlightEnvelopeSystem(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.dataset_outlined,
                        title: 'Komponent Veri Kaynağı',
                      ),
                      const SizedBox(height: 16),
                      _buildMotorPropellerSelection(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.bolt,
                        title: 'Motor Sistemi',
                      ),
                      const SizedBox(height: 16),
                      _buildMotorSystem(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.battery_charging_full,
                        title: 'Batarya Sistemi',
                      ),
                      const SizedBox(height: 16),
                      _buildBatterySystem(),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        icon: Icons.toys_outlined,
                        title: 'Pervane Sistemi',
                      ),
                      const SizedBox(height: 16),
                      _buildPropellerSystem(),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInformation() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Araç Adı',
            hint: 'Örnek: UAV-X Prototype',
            icon: Icons.badge_outlined,
          ),
          validator: (value) => _validateRequiredText(value, 'Araç adı'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedType),
          initialValue: _selectedType,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Araç Türü',
            hint: 'Araç türünü seçin',
            icon: Icons.category_outlined,
          ),
          items: _aircraftTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhysicalProperties() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final weightField = TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Ağırlık',
            hint: '2.35',
            icon: Icons.monitor_weight_outlined,
            suffixText: 'kg',
          ),
          validator: (value) => _validatePositiveNumber(value, 'Ağırlık'),
        );

        final wingAreaField = TextFormField(
          controller: _wingAreaController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Kanat Alanı',
            hint: '0.46',
            icon: Icons.airplanemode_active,
            suffixText: 'm²',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Kanat alanı', allowZero: true),
        );

        final wingSpanField = TextFormField(
          controller: _wingSpanController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Kanat Açıklığı',
            hint: '1.40',
            icon: Icons.straighten,
            suffixText: 'm',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Kanat açıklığı', allowZero: true),
        );

        if (isNarrow) {
          return Column(
            children: [
              weightField,
              const SizedBox(height: 16),
              wingAreaField,
              const SizedBox(height: 16),
              wingSpanField,
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: weightField),
                const SizedBox(width: 16),
                Expanded(child: wingAreaField),
              ],
            ),
            const SizedBox(height: 16),
            wingSpanField,
          ],
        );
      },
    );
  }

  Widget _buildAerodynamicPerformance() {
    final isWingedAircraft =
        _selectedType == 'Sabit Kanat' || _selectedType == 'VTOL';

    final cd0Field = TextFormField(
      controller: _zeroLiftDragCoefficientController,
      enabled: isWingedAircraft,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
        label: 'Sıfır Kaldırma Sürükleme Katsayısı (Cd0)',
        hint: '0.030',
        icon: Icons.air_outlined,
      ),
      validator: (value) => _validatePositiveNumber(value, 'Cd0'),
    );

    final clMaxField = TextFormField(
      controller: _maxLiftCoefficientController,
      enabled: isWingedAircraft,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
        label: 'Maksimum Kaldırma Katsayısı (CLmax)',
        hint: '1.4',
        icon: Icons.flight_outlined,
      ),
      validator: (value) => _validatePositiveNumber(value, 'CLmax'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _cruiseSpeedController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Seyir Hızı',
            hint: '18',
            icon: Icons.speed_outlined,
            suffixText: 'm/s',
          ),
          validator: (value) => _validatePositiveNumber(value, 'Seyir hızı'),
        ),
        const SizedBox(height: 16),
        if (!isWingedAircraft)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Aerodinamik katsayılar drone ve helikopter analizlerinde '
              'kullanılmaz; kayıt tutarlılığı için varsayılan değerlerle '
              'saklanır.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 500) {
              return Column(
                children: [cd0Field, const SizedBox(height: 16), clMaxField],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cd0Field),
                const SizedBox(width: 16),
                Expanded(child: clMaxField),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oswaldEfficiencyController,
          enabled: isWingedAircraft,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Oswald Verimlilik Faktörü',
            hint: '80',
            icon: Icons.percent_outlined,
            suffixText: '%',
          ),
          validator: (value) =>
              _validateEfficiencyPercent(value, 'Oswald verimlilik faktörü'),
        ),
      ],
    );
  }

  Widget _buildStabilitySystem() {
    Widget numberField({
      required TextEditingController controller,
      required String label,
      required String hint,
      required String suffix,
      bool allowZero = false,
    }) {
      return TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(
          label: label,
          hint: hint,
          icon: Icons.straighten_outlined,
          suffixText: suffix,
        ),
        validator: (value) =>
            _validatePositiveNumber(value, label, allowZero: allowZero),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datum noktası araç burnunda kabul edilir. Tüm boylamsal '
          'konumlar datumdan geriye doğru metre cinsindendir.',
          style: TextStyle(color: Color(0xFF627D98)),
        ),
        const SizedBox(height: 16),
        numberField(
          controller: _meanAerodynamicChordController,
          label: 'Ortalama Aerodinamik Kord',
          hint: '0.30',
          suffix: 'm',
          allowZero: true,
        ),
        const SizedBox(height: 16),
        numberField(
          controller: _macLeadingEdgeController,
          label: 'MAC Hücum Kenarı / Datum',
          hint: '0.40',
          suffix: 'm',
          allowZero: true,
        ),
        const SizedBox(height: 16),
        numberField(
          controller: _neutralPointPercentController,
          label: 'Nötr Nokta',
          hint: '40',
          suffix: '% MAC',
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: numberField(
                controller: _minimumCgPercentController,
                label: 'Minimum CG Limiti',
                hint: '20',
                suffix: '% MAC',
                allowZero: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: numberField(
                controller: _maximumCgPercentController,
                label: 'Maksimum CG Limiti',
                hint: '35',
                suffix: '% MAC',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMassStationFields(
          title: 'Motor Sistemi',
          massController: _motorMassController,
          armController: _motorArmController,
        ),
        const SizedBox(height: 18),
        _buildMassStationFields(
          title: 'Batarya',
          massController: _batteryMassController,
          armController: _batteryArmController,
        ),
        const SizedBox(height: 18),
        _buildMassStationFields(
          title: 'Gövde',
          massController: _airframeMassController,
          armController: _airframeArmController,
        ),
        const SizedBox(height: 18),
        _buildMassStationFields(
          title: 'Faydalı Yük',
          massController: _payloadMassController,
          armController: _payloadArmController,
        ),
      ],
    );
  }

  Widget _buildMassStationFields({
    required String title,
    required TextEditingController massController,
    required TextEditingController armController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF243B53),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: massController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: '$title Kütlesi',
                  hint: '0.50',
                  icon: Icons.monitor_weight_outlined,
                  suffixText: 'kg',
                ),
                validator: (value) => _validatePositiveNumber(
                  value,
                  '$title kütlesi',
                  allowZero: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: armController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: '$title Konumu',
                  hint: '0.40',
                  icon: Icons.swap_horiz_outlined,
                  suffixText: 'm',
                ),
                validator: (value) => _validatePositiveNumber(
                  value,
                  '$title konumu',
                  allowZero: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightEnvelopeSystem() {
    return Column(
      children: [
        TextFormField(
          controller: _maximumOperatingSpeedController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Maksimum İşletme Hızı',
            hint: '25',
            icon: Icons.speed_outlined,
            suffixText: 'm/s',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Maksimum işletme hızı'),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _positiveLimitLoadFactorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Pozitif Limit Yük Faktörü',
                  hint: '3.8',
                  icon: Icons.arrow_upward_outlined,
                  suffixText: 'g',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    value?.trim().replaceAll(',', '.') ?? '',
                  );

                  if (parsed == null || parsed <= 1.0) {
                    return 'Pozitif yük faktörü 1.0 değerinden büyük olmalıdır';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _negativeLimitLoadFactorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Negatif Limit Yük Faktörü',
                  hint: '-1.5',
                  icon: Icons.arrow_downward_outlined,
                  suffixText: 'g',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    value?.trim().replaceAll(',', '.') ?? '',
                  );

                  if (parsed == null || parsed >= 0.0) {
                    return 'Negatif yük faktörü sıfırdan küçük olmalıdır';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotorPropellerSelection() {
    final selectedCombination = _selectedMotorPropellerCombination;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          key: ValueKey(_selectedMotorPropellerCombinationId),
          initialValue: _selectedMotorPropellerCombinationId,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Motor–Pervane Veri Kaynağı',
            hint: 'Manuel giriş veya gerçek test tablosu seçin',
            icon: Icons.table_chart_outlined,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Manuel giriş'),
            ),
            ..._motorPropellerCombinations.map((combination) {
              return DropdownMenuItem<String?>(
                value: combination.id,
                child: Text(
                  _combinationTitle(combination),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMotorPropellerCombinationId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3D91).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF0B3D91).withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selectedCombination == null
                    ? Icons.edit_note_outlined
                    : Icons.verified_outlined,
                color: const Color(0xFF0B3D91),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCombination == null
                          ? 'Manuel komponent girişi'
                          : 'Gerçek test tablosu seçildi',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243B53),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCombination == null
                          ? 'Motor gücü, verim ve pervane çapı alanları '
                                'manuel olarak kullanılacaktır.'
                          : _combinationSubtitle(selectedCombination),
                      style: const TextStyle(
                        height: 1.35,
                        color: Color(0xFF627D98),
                      ),
                    ),
                    if (selectedCombination != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedCombination.dataSource,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: Color(0xFF829AB1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotorSystem() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final motorCountField = TextFormField(
          controller: _motorCountController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Motor Sayısı',
            hint: '1',
            icon: Icons.settings_input_component_outlined,
            suffixText: 'adet',
          ),
          validator: (value) => _validateInteger(value, 'Motor sayısı'),
        );

        final motorPowerField = TextFormField(
          controller: _motorPowerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Kurulu Motor Gücü',
            hint: '1200',
            icon: Icons.electric_bolt_outlined,
            suffixText: 'W',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Kurulu motor gücü'),
        );

        final escEfficiencyField = TextFormField(
          controller: _escEfficiencyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'ESC Verimi',
            hint: '95',
            icon: Icons.speed_outlined,
            suffixText: '%',
          ),
          validator: (value) => _validateEfficiencyPercent(value, 'ESC verimi'),
        );

        final motorEfficiencyField = TextFormField(
          controller: _motorEfficiencyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Motor Verimi',
            hint: '85',
            icon: Icons.settings_outlined,
            suffixText: '%',
          ),
          validator: (value) =>
              _validateEfficiencyPercent(value, 'Motor verimi'),
        );

        final continuousPowerField = TextFormField(
          controller: _continuousMotorPowerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Sürekli Motor Gücü',
            hint: '1000',
            icon: Icons.timeline_outlined,
            suffixText: 'W',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Sürekli motor gücü'),
          onChanged: (_) {
            _formKey.currentState?.validate();
          },
        );

        final maximumPowerField = TextFormField(
          controller: _maximumMotorPowerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Maksimum Motor Gücü',
            hint: '1200',
            icon: Icons.bolt_outlined,
            suffixText: 'W',
          ),
          validator: _validateMaximumMotorPower,
        );

        final fields = <Widget>[
          motorCountField,
          motorPowerField,
          escEfficiencyField,
          motorEfficiencyField,
          continuousPowerField,
          maximumPowerField,
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: motorCountField),
                const SizedBox(width: 16),
                Expanded(child: motorPowerField),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: escEfficiencyField),
                const SizedBox(width: 16),
                Expanded(child: motorEfficiencyField),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: continuousPowerField),
                const SizedBox(width: 16),
                Expanded(child: maximumPowerField),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBatterySystem() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final batteryTypeField = DropdownButtonFormField<String>(
          key: ValueKey(_selectedBatteryType),
          initialValue: _selectedBatteryType,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Batarya Tipi',
            hint: 'Batarya kimyasını seçin',
            icon: Icons.battery_std_outlined,
          ),
          items: _batteryTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedBatteryType = value;
                _applyBatteryChemistryDefault(value);
              });
              _formKey.currentState?.validate();
            }
          },
        );

        final batteryCellField = TextFormField(
          controller: _batteryCellController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Hücre Sayısı',
            hint: '6',
            icon: Icons.view_module_outlined,
            suffixText: 'S',
          ),
          validator: (value) => _validateInteger(value, 'Hücre sayısı'),
          onChanged: (_) {
            _formKey.currentState?.validate();
          },
        );

        final batteryVoltageField = TextFormField(
          controller: _batteryVoltageController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Batarya Voltajı',
            hint: '22.2',
            icon: Icons.electric_meter_outlined,
            suffixText: 'V',
          ),
          validator: _validateBatteryVoltage,
        );

        final batteryCapacityField = TextFormField(
          controller: _batteryCapacityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Batarya Kapasitesi',
            hint: '5000',
            icon: Icons.battery_full_outlined,
            suffixText: 'mAh',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Batarya kapasitesi'),
        );

        final cellInternalResistanceField = TextFormField(
          controller: _cellInternalResistanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Hücre İç Direnci',
            hint: '4.0',
            icon: Icons.electrical_services_outlined,
            suffixText: 'mΩ/hücre',
          ),
          validator: (value) =>
              _validatePositiveNumber(value, 'Hücre iç direnci'),
        );

        final batteryDescriptionField = TextFormField(
          controller: _batteryController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Batarya Modeli / Açıklaması',
            hint: 'Örnek: Tattu 6S 5000 mAh',
            icon: Icons.description_outlined,
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              batteryTypeField,
              const SizedBox(height: 16),
              batteryCellField,
              const SizedBox(height: 16),
              batteryVoltageField,
              const SizedBox(height: 16),
              batteryCapacityField,
              const SizedBox(height: 16),
              cellInternalResistanceField,
              const SizedBox(height: 16),
              batteryDescriptionField,
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: batteryTypeField),
                const SizedBox(width: 16),
                Expanded(child: batteryCellField),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: batteryVoltageField),
                const SizedBox(width: 16),
                Expanded(child: batteryCapacityField),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cellInternalResistanceField),
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),
            batteryDescriptionField,
          ],
        );
      },
    );
  }

  Widget _buildPropellerSystem() {
    return TextFormField(
      controller: _propellerDiameterController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        _submitForm();
      },
      decoration: _inputDecoration(
        label: 'Pervane Çapı',
        hint: '12',
        icon: Icons.toys_outlined,
        suffixText: 'inç',
      ),
      validator: (value) => _validatePositiveNumber(value, 'Pervane çapı'),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3D91).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              widget.isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
              color: const Color(0xFF0B3D91),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Aracı Düzenle' : 'Yeni Araç Oluştur',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEditing
                      ? 'Kayıtlı araç bilgilerini güncelleyin.'
                      : 'Kütüphaneye yeni bir hava aracı ekleyin.',
                  style: const TextStyle(color: Color(0xFF627D98)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Kapat',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _submitForm,
            icon: Icon(widget.isEditing ? Icons.save_outlined : Icons.add),
            label: Text(
              widget.isEditing ? 'Değişiklikleri Kaydet' : 'Aracı Ekle',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 21, color: const Color(0xFF0B3D91)),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF243B53),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixText: suffixText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
