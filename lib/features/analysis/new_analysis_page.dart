import 'package:flutter/material.dart';

import 'analysis_result_page.dart';
import 'models/aircraft.dart';
import 'models/environment.dart';
import 'services/air_density_service.dart';
import 'services/analysis_service.dart';
import 'services/battery_chemistry_service.dart';
import 'services/battery_validation_service.dart';
import 'widgets/analysis_section.dart';

class NewAnalysisPage extends StatefulWidget {
  final Aircraft? initialAircraft;

  const NewAnalysisPage({super.key, this.initialAircraft});

  @override
  State<NewAnalysisPage> createState() => _NewAnalysisPageState();
}

class _NewAnalysisPageState extends State<NewAnalysisPage> {
  final _formKey = GlobalKey<FormState>();
  final BatteryChemistryService _batteryChemistryService =
      BatteryChemistryService();

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _wingAreaController;
  late final TextEditingController _wingSpanController;
  late final TextEditingController _motorPowerController;
  late final TextEditingController _motorCountController;
  late final TextEditingController _escEfficiencyController;
  late final TextEditingController _motorEfficiencyController;
  late final TextEditingController _continuousMotorPowerController;
  late final TextEditingController _maximumMotorPowerController;
  late final TextEditingController _propellerDiameterController;
  late final TextEditingController _batteryCapacityController;
  late final TextEditingController _batteryVoltageController;
  late final TextEditingController _batteryCellController;
  late final TextEditingController _cellInternalResistanceController;
  late final TextEditingController _altitudeController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _humidityController;
  late final TextEditingController _windSpeedController;

  String _batteryType = 'LiPo';
  String _selectedAircraftType = 'Drone';
  String _windDirection = 'Karşıdan';

  @override
  void initState() {
    super.initState();

    final aircraft = widget.initialAircraft;

    final batteryType = aircraft?.batteryType;
    if (batteryType == 'LiPo' ||
        batteryType == 'Li-Ion' ||
        batteryType == 'LiHV') {
      _batteryType = batteryType!;
    }

    _nameController = TextEditingController(
      text: aircraft?.name ?? 'Eğitim Drone V1',
    );
    _weightController = TextEditingController(
      text: aircraft?.weightKg.toString() ?? '2.4',
    );
    _wingAreaController = TextEditingController(
      text: aircraft?.wingAreaM2.toString() ?? '0.45',
    );
    _wingSpanController = TextEditingController(
      text: aircraft?.wingSpanM.toString() ?? '1.2',
    );
    _motorPowerController = TextEditingController(
      text: aircraft?.motorPowerW.toString() ?? '850',
    );
    _motorCountController = TextEditingController(
      text: aircraft?.motorCount.toString() ?? '4',
    );
    _escEfficiencyController = TextEditingController(
      text: ((aircraft?.escEfficiency ?? 0.95) * 100).toStringAsFixed(0),
    );
    _motorEfficiencyController = TextEditingController(
      text: ((aircraft?.motorEfficiency ?? 0.85) * 100).toStringAsFixed(0),
    );
    _continuousMotorPowerController = TextEditingController(
      text:
          aircraft?.continuousMotorPowerW.toString() ??
          aircraft?.motorPowerW.toString() ??
          '850',
    );
    _maximumMotorPowerController = TextEditingController(
      text:
          aircraft?.maximumMotorPowerW.toString() ??
          aircraft?.motorPowerW.toString() ??
          '850',
    );
    _propellerDiameterController = TextEditingController(
      text: aircraft?.propellerDiameterInch.toString() ?? '10',
    );
    _batteryCapacityController = TextEditingController(
      text: aircraft?.batteryCapacityMah.toString() ?? '5200',
    );
    _batteryVoltageController = TextEditingController(
      text: aircraft?.batteryVoltageV.toString() ?? '14.8',
    );
    _batteryCellController = TextEditingController(
      text: aircraft?.batteryCellCount.toString() ?? '4',
    );
    _cellInternalResistanceController = TextEditingController(
      text:
          aircraft?.cellInternalResistanceMilliOhm.toString() ??
          _defaultCellInternalResistanceMilliOhm(_batteryType).toString(),
    );
    _altitudeController = TextEditingController(text: '50');
    _temperatureController = TextEditingController(text: '25');
    _humidityController = TextEditingController(text: '40');
    _windSpeedController = TextEditingController(text: '12');

    final aircraftType = aircraft?.type;
    if (aircraftType == 'Drone' ||
        aircraftType == 'Sabit Kanat' ||
        aircraftType == 'VTOL') {
      _selectedAircraftType = aircraftType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _wingAreaController.dispose();
    _wingSpanController.dispose();
    _motorPowerController.dispose();
    _motorCountController.dispose();
    _escEfficiencyController.dispose();
    _motorEfficiencyController.dispose();
    _continuousMotorPowerController.dispose();
    _maximumMotorPowerController.dispose();
    _propellerDiameterController.dispose();
    _batteryCapacityController.dispose();
    _batteryVoltageController.dispose();
    _batteryCellController.dispose();
    _cellInternalResistanceController.dispose();
    _altitudeController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _windSpeedController.dispose();

    super.dispose();
  }

  double _toDouble(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
  }

  double _toEfficiency(TextEditingController controller) {
    return _toDouble(controller) / 100.0;
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

  String? _validateMaximumMotorPower(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Maksimum Motor Gücü (W) boş bırakılamaz';
    }

    final maximumPower = double.tryParse(value.trim().replaceAll(',', '.'));
    final continuousPower = _toDouble(_continuousMotorPowerController);

    if (maximumPower == null) {
      return 'Maksimum Motor Gücü (W) için geçerli bir sayı giriniz';
    }

    if (maximumPower <= 0) {
      return 'Maksimum Motor Gücü (W) sıfırdan büyük olmalıdır';
    }

    if (maximumPower < continuousPower) {
      return 'Maksimum güç, sürekli güçten küçük olamaz';
    }

    return null;
  }

  void _startAnalysis() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final batteryValidator = BatteryValidationService();

    final isBatteryVoltageValid = batteryValidator.isVoltageValid(
      batteryType: _batteryType,
      cellCount: _toDouble(_batteryCellController).toInt(),
      enteredVoltage: _toDouble(_batteryVoltageController),
    );

    if (!isBatteryVoltageValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Batarya voltajı seçilen batarya tipi ve hücre sayısı ile uyumlu görünmüyor.',
          ),
        ),
      );
      return;
    }

    final aircraft = Aircraft(
      name: _nameController.text.trim(),
      type: _selectedAircraftType,
      weightKg: _toDouble(_weightController),
      wingAreaM2: _toDouble(_wingAreaController),
      wingSpanM: _toDouble(_wingSpanController),
      motorCount: _toDouble(_motorCountController).toInt(),
      motorPowerW: _toDouble(_motorPowerController),
      escEfficiency: _toEfficiency(_escEfficiencyController),
      motorEfficiency: _toEfficiency(_motorEfficiencyController),
      continuousMotorPowerW: _toDouble(_continuousMotorPowerController),
      maximumMotorPowerW: _toDouble(_maximumMotorPowerController),
      propellerDiameterInch: _toDouble(_propellerDiameterController),
      batteryCapacityMah: _toDouble(_batteryCapacityController),
      batteryVoltageV: _toDouble(_batteryVoltageController),
      batteryType: _batteryType,
      batteryCellCount: _toDouble(_batteryCellController).toInt(),
      cellInternalResistanceMilliOhm: _toDouble(
        _cellInternalResistanceController,
      ),
      motorComponentId: widget.initialAircraft?.motorComponentId,
      propellerComponentId: widget.initialAircraft?.propellerComponentId,
      batteryComponentId: widget.initialAircraft?.batteryComponentId,
      escComponentId: widget.initialAircraft?.escComponentId,
      motorPropellerCombinationId:
          widget.initialAircraft?.motorPropellerCombinationId,
    );

    final altitudeM = _toDouble(_altitudeController);
    final temperatureC = _toDouble(_temperatureController);

    // Basınç kullanıcıdan ayrı bir giriş olarak alınmıyor.
    // Seçilen irtifadaki ISA standart basıncı otomatik hesaplanıyor.
    final pressureHpa = AirDensityService().calculateIsaPressureHpa(
      altitudeM: altitudeM,
    );

    final environment = Environment(
      altitudeM: altitudeM,
      temperatureC: temperatureC,
      pressureHpa: pressureHpa,
      humidityPercent: _toDouble(_humidityController),
      windSpeedKmh: _toDouble(_windSpeedController),
      windDirection: _windDirection,
    );

    final result = AnalysisService().analyze(aircraft, environment);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalysisResultPage(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final openedFromHangar = widget.initialAircraft != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(openedFromHangar ? 'Araç Analizi' : 'Yeni Analiz'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        openedFromHangar
                            ? 'Kayıtlı Araç Analizi'
                            : 'Yeni Uçuş Analizi',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102A43),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        openedFromHangar
                            ? 'Araç Kütüphanesi verileri forma aktarıldı. Analiz koşullarını kontrol ederek analizi başlatın.'
                            : 'Hava aracı ve çevre bilgilerini girerek performans analizi oluştur.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF627D98),
                        ),
                      ),
                      const SizedBox(height: 28),

                      AnalysisSection(
                        title: 'Genel Bilgiler',
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              key: ValueKey(_selectedAircraftType),
                              initialValue: _selectedAircraftType,
                              decoration: const InputDecoration(
                                labelText: 'Araç Tipi',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Drone',
                                  child: Text('Drone'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sabit Kanat',
                                  child: Text('Sabit Kanat'),
                                ),
                                DropdownMenuItem(
                                  value: 'VTOL',
                                  child: Text('VTOL'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAircraftType = value ?? 'Drone';
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              'Araç Adı',
                              _nameController,
                              numeric: false,
                            ),
                          ],
                        ),
                      ),

                      AnalysisSection(
                        title: 'Aerodinamik',
                        child: Column(
                          children: [
                            _buildTextField('Ağırlık (kg)', _weightController),
                            _buildTextField(
                              'Kanat Alanı (m²)',
                              _wingAreaController,
                              allowZero: true,
                            ),
                            _buildTextField(
                              'Kanat Açıklığı (m)',
                              _wingSpanController,
                              allowZero: true,
                            ),
                          ],
                        ),
                      ),

                      AnalysisSection(
                        title: 'Motor ve Propulsion',
                        child: Column(
                          children: [
                            _buildTextField(
                              'Kurulu Motor Gücü (W)',
                              _motorPowerController,
                            ),
                            _buildTextField(
                              'Motor Sayısı',
                              _motorCountController,
                              integerOnly: true,
                            ),
                            _buildTextField(
                              'ESC Verimi (%)',
                              _escEfficiencyController,
                              minimumValue: 0.1,
                              maximumValue: 100,
                            ),
                            _buildTextField(
                              'Motor Verimi (%)',
                              _motorEfficiencyController,
                              minimumValue: 0.1,
                              maximumValue: 100,
                            ),
                            _buildTextField(
                              'Sürekli Motor Gücü (W)',
                              _continuousMotorPowerController,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: TextFormField(
                                controller: _maximumMotorPowerController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Maksimum Motor Gücü (W)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateMaximumMotorPower,
                              ),
                            ),
                            _buildTextField(
                              'Pervane Çapı (inch)',
                              _propellerDiameterController,
                            ),
                          ],
                        ),
                      ),

                      AnalysisSection(
                        title: 'Batarya',
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              key: ValueKey(_batteryType),
                              initialValue: _batteryType,
                              decoration: const InputDecoration(
                                labelText: 'Batarya Tipi',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'LiPo',
                                  child: Text('LiPo'),
                                ),
                                DropdownMenuItem(
                                  value: 'Li-Ion',
                                  child: Text('Li-Ion'),
                                ),
                                DropdownMenuItem(
                                  value: 'LiHV',
                                  child: Text('LiHV'),
                                ),
                              ],
                              onChanged: (value) {
                                final selectedType = value ?? 'LiPo';
                                setState(() {
                                  _batteryType = selectedType;
                                  _applyBatteryChemistryDefault(selectedType);
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              'Batarya Kapasitesi (mAh)',
                              _batteryCapacityController,
                            ),
                            _buildTextField(
                              'Batarya Voltajı (V)',
                              _batteryVoltageController,
                            ),
                            _buildTextField(
                              'Hücre Sayısı (S)',
                              _batteryCellController,
                              integerOnly: true,
                            ),
                            _buildTextField(
                              'Hücre İç Direnci (mΩ/hücre)',
                              _cellInternalResistanceController,
                              minimumValue: 0.1,
                            ),
                          ],
                        ),
                      ),

                      AnalysisSection(
                        title: 'Çevre ve ISA Koşulları',
                        child: Column(
                          children: [
                            _buildTextField(
                              'İrtifa (m)',
                              _altitudeController,
                              allowZero: true,
                              minimumValue: -500,
                              maximumValue: 20000,
                            ),
                            _buildTextField(
                              'Ortam Sıcaklığı (°C)',
                              _temperatureController,
                              allowNegative: true,
                              minimumValue: -100,
                              maximumValue: 100,
                            ),
                            _buildTextField(
                              'Bağıl Nem (%)',
                              _humidityController,
                              allowZero: true,
                              minimumValue: 0,
                              maximumValue: 100,
                            ),
                            _buildTextField(
                              'Rüzgâr Hızı (km/h)',
                              _windSpeedController,
                              allowZero: true,
                              minimumValue: 0,
                            ),
                            DropdownButtonFormField<String>(
                              key: ValueKey(_windDirection),
                              initialValue: _windDirection,
                              decoration: const InputDecoration(
                                labelText: 'Rüzgâr Yönü',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Karşıdan',
                                  child: Text('Karşıdan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Arkadan',
                                  child: Text('Arkadan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Soldan',
                                  child: Text('Soldan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sağdan',
                                  child: Text('Sağdan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sakin',
                                  child: Text('Sakin'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _windDirection = value ?? 'Karşıdan';
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Not: Atmosfer basıncı, seçilen irtifaya göre ISA modeliyle otomatik hesaplanır.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF627D98),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _startAnalysis,
                          icon: const Icon(Icons.analytics),
                          label: const Text(
                            'Analizi Başlat',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool numeric = true,
    bool allowZero = false,
    bool allowNegative = false,
    bool integerOnly = false,
    double? minimumValue,
    double? maximumValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label boş bırakılamaz';
          }

          if (!numeric) {
            return null;
          }

          final number = double.tryParse(value.trim().replaceAll(',', '.'));

          if (number == null) {
            return '$label için geçerli bir sayı giriniz';
          }

          if (!allowNegative && (allowZero ? number < 0 : number <= 0)) {
            return allowZero
                ? '$label negatif olamaz'
                : '$label sıfırdan büyük olmalıdır';
          }

          if (minimumValue != null && number < minimumValue) {
            return '$label en az $minimumValue olmalıdır';
          }

          if (maximumValue != null && number > maximumValue) {
            return '$label en fazla $maximumValue olmalıdır';
          }

          if (integerOnly && number != number.roundToDouble()) {
            return '$label tam sayı olmalıdır';
          }

          return null;
        },
      ),
    );
  }
}
