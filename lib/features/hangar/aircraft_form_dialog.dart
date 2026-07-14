import 'package:flutter/material.dart';

import '../analysis/services/battery_validation_service.dart';

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

  // Genel bilgiler
  late final TextEditingController _nameController;

  // Fiziksel özellikler
  late final TextEditingController _weightController;
  late final TextEditingController _wingAreaController;
  late final TextEditingController _wingSpanController;

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

  // Pervane sistemi
  late final TextEditingController _propellerDiameterController;

  late String _selectedType;
  late String _selectedBatteryType;

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

    _propellerDiameterController = TextEditingController(
      text: aircraft?['propellerDiameter']?.toString() ?? '',
    );

    final existingType = aircraft?['type']?.toString();
    _selectedType = _aircraftTypes.contains(existingType)
        ? existingType!
        : 'Sabit Kanat';

    final existingBatteryType = aircraft?['batteryType']?.toString();
    _selectedBatteryType = _batteryTypes.contains(existingBatteryType)
        ? existingBatteryType!
        : 'LiPo';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _wingAreaController.dispose();
    _wingSpanController.dispose();
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
    _propellerDiameterController.dispose();
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

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final batteryCellCount = _parseInt(_batteryCellController);
    final batterySummary = _batteryController.text.trim().isEmpty
        ? '${batteryCellCount}S $_selectedBatteryType'
        : _batteryController.text.trim();

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'weight': _parseDouble(_weightController),
      'wingArea': _parseDouble(_wingAreaController),
      'wingSpan': _parseDouble(_wingSpanController),
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
      'propellerDiameter': _parseDouble(_propellerDiameterController),
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
