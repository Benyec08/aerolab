import 'package:flutter/material.dart';

import 'analysis_result_page.dart';
import 'models/aircraft.dart';
import 'models/environment.dart';
import 'services/analysis_service.dart';
import 'services/battery_validation_service.dart';
import 'widgets/analysis_section.dart';

class NewAnalysisPage extends StatefulWidget {
  final Map<String, dynamic>? initialAircraft;

  const NewAnalysisPage({super.key, this.initialAircraft});

  @override
  State<NewAnalysisPage> createState() => _NewAnalysisPageState();
}

class _NewAnalysisPageState extends State<NewAnalysisPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _wingAreaController;
  late final TextEditingController _wingSpanController;
  late final TextEditingController _motorPowerController;
  late final TextEditingController _motorCountController;
  late final TextEditingController _propellerDiameterController;
  late final TextEditingController _batteryCapacityController;
  late final TextEditingController _batteryVoltageController;
  late final TextEditingController _batteryCellController;
  late final TextEditingController _windSpeedController;

  String _batteryType = 'LiPo';
  String _selectedAircraftType = 'Drone';

  @override
  void initState() {
    super.initState();

    final aircraft = widget.initialAircraft;

    _nameController = TextEditingController(
      text: aircraft?['name']?.toString() ?? 'Eğitim Drone V1',
    );
    _weightController = TextEditingController(
      text: aircraft?['weight']?.toString() ?? '2.4',
    );
    _wingAreaController = TextEditingController(
      text: aircraft?['wingArea']?.toString() ?? '0.45',
    );
    _wingSpanController = TextEditingController(
      text: aircraft?['wingSpan']?.toString() ?? '1.2',
    );
    _motorPowerController = TextEditingController(
      text: aircraft?['motorPower']?.toString() ?? '850',
    );
    _motorCountController = TextEditingController(
      text: aircraft?['motorCount']?.toString() ?? '4',
    );
    _propellerDiameterController = TextEditingController(
      text: aircraft?['propellerDiameter']?.toString() ?? '10',
    );
    _batteryCapacityController = TextEditingController(
      text: aircraft?['batteryCapacity']?.toString() ?? '5200',
    );
    _batteryVoltageController = TextEditingController(
      text: aircraft?['batteryVoltage']?.toString() ?? '14.8',
    );
    _batteryCellController = TextEditingController(
      text: aircraft?['batteryCellCount']?.toString() ?? '4',
    );
    _windSpeedController = TextEditingController(text: '12');

    final aircraftType = aircraft?['type']?.toString();
    if (aircraftType == 'Drone' ||
        aircraftType == 'Sabit Kanat' ||
        aircraftType == 'VTOL') {
      _selectedAircraftType = aircraftType!;
    }

    final batteryType = aircraft?['batteryType']?.toString();
    if (batteryType == 'LiPo' ||
        batteryType == 'Li-Ion' ||
        batteryType == 'LiHV') {
      _batteryType = batteryType!;
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
    _propellerDiameterController.dispose();
    _batteryCapacityController.dispose();
    _batteryVoltageController.dispose();
    _batteryCellController.dispose();
    _windSpeedController.dispose();

    super.dispose();
  }

  double _toDouble(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
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
      propellerDiameterInch: _toDouble(_propellerDiameterController),
      batteryCapacityMah: _toDouble(_batteryCapacityController),
      batteryVoltageV: _toDouble(_batteryVoltageController),
      batteryType: _batteryType,
      batteryCellCount: _toDouble(_batteryCellController).toInt(),
    );

    final environment = Environment(
      altitudeM: 50,
      temperatureC: 25,
      pressureHpa: 1013,
      humidityPercent: 40,
      windSpeedKmh: _toDouble(_windSpeedController),
      windDirection: 'Karşıdan',
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
                        title: 'Motor',
                        child: Column(
                          children: [
                            _buildTextField(
                              'Motor Gücü (W)',
                              _motorPowerController,
                            ),
                            _buildTextField(
                              'Motor Sayısı',
                              _motorCountController,
                              integerOnly: true,
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
                                setState(() {
                                  _batteryType = value ?? 'LiPo';
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
                          ],
                        ),
                      ),

                      AnalysisSection(
                        title: 'Çevre',
                        child: Column(
                          children: [
                            _buildTextField(
                              'Rüzgâr Hızı (km/h)',
                              _windSpeedController,
                              allowZero: true,
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
    bool integerOnly = false,
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

          if (allowZero ? number < 0 : number <= 0) {
            return allowZero
                ? '$label negatif olamaz'
                : '$label sıfırdan büyük olmalıdır';
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
