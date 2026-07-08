import 'package:flutter/material.dart';

import 'analysis_result_page.dart';
import 'models/aircraft.dart';
import 'models/environment.dart';
import 'services/analysis_service.dart';
import 'widgets/analysis_section.dart';
import 'services/battery_validation_service.dart';

class NewAnalysisPage extends StatefulWidget {
  const NewAnalysisPage({super.key});

  @override
  State<NewAnalysisPage> createState() => _NewAnalysisPageState();
}

class _NewAnalysisPageState extends State<NewAnalysisPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Eğitim Drone V1');
  final _weightController = TextEditingController(text: '2.4');
  final _wingAreaController = TextEditingController(text: '0.45');
  final _wingSpanController = TextEditingController(text: '1.2');
  final _motorPowerController = TextEditingController(text: '850');
  final _motorCountController = TextEditingController(text: '4');
  final _propellerDiameterController = TextEditingController(text: '10');
  final _batteryCapacityController = TextEditingController(text: '5200');
  final _batteryVoltageController = TextEditingController(text: '14.8');
  final _batteryCellController = TextEditingController(text: '4');

  String _batteryType = 'LiPo';
  final _windSpeedController = TextEditingController(text: '12');

  String _selectedAircraftType = 'Drone';

  @override
  void dispose() {
    _motorCountController.dispose();
    _propellerDiameterController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _wingAreaController.dispose();
    _wingSpanController.dispose();
    _motorPowerController.dispose();
    _batteryCapacityController.dispose();
    _batteryVoltageController.dispose();
    _batteryCellController.dispose();
    _windSpeedController.dispose();

    super.dispose();
  }

  double _toDouble(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  void _startAnalysis() {
    if (!_formKey.currentState!.validate()) {
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
      name: _nameController.text,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Yeni Analiz'),
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
                      const Text(
                        'Yeni Uçuş Analizi',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102A43),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hava aracı ve çevre bilgilerini girerek performans analizi oluştur.',
                        style: TextStyle(
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

                            _buildTextField('Araç Adı', _nameController),
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
                            ),
                            _buildTextField(
                              'Kanat Açıklığı (m)',
                              _wingSpanController,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }
}
