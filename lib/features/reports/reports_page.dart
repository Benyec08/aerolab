import 'package:flutter/material.dart';

import '../../data/entities/analysis_history_entity.dart';
import '../../data/services/analysis_history_service.dart';
import '../analysis/models/aircraft.dart';
import '../analysis/models/analysis_result.dart';
import '../analysis/models/environment.dart';

class ReportsPage extends StatefulWidget {
  final AnalysisHistoryService? historyService;

  const ReportsPage({super.key, this.historyService});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final AnalysisHistoryService _historyService;
  List<AnalysisHistoryEntity> _history = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? AnalysisHistoryService();
    _loadReports();
  }

  void _loadReports() {
    try {
      setState(() {
        _history = _historyService.getAllAnalyses();
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _history = const [];
        _errorMessage = 'Rapor kayıtları yüklenemedi: $error';
      });
    }
  }

  Future<void> _openReport(AnalysisHistoryEntity history) async {
    try {
      final aircraft = _historyService.restoreAircraft(history);
      final environment = _historyService.restoreEnvironment(history);
      final result = _historyService.restoreResult(history);

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EngineeringReportPage(
            history: history,
            aircraft: aircraft,
            environment: environment,
            result: result,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rapor açılamadı: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Raporlar'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _ReportMessageState(
        icon: Icons.error_outline,
        title: 'Raporlar yüklenemedi',
        message: _errorMessage!,
        actionLabel: 'Tekrar Dene',
        onAction: _loadReports,
      );
    }

    if (_history.isEmpty) {
      return const _ReportMessageState(
        icon: Icons.description_outlined,
        title: 'Henüz rapor oluşturulabilecek analiz yok',
        message:
            'Bir analiz tamamladığınızda mühendislik raporu burada kullanılabilir olacak.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_history.length} kullanılabilir rapor',
          style: const TextStyle(fontSize: 15, color: Color(0xFF627D98)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _history.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final history = _history[index];

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFD9E2EC)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openReport(history),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEF9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF0B3D91),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history.aircraftName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF102A43),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 12,
                                runSpacing: 5,
                                children: [
                                  _ReportMeta(
                                    icon: Icons.flight_outlined,
                                    text: history.aircraftType,
                                  ),
                                  _ReportMeta(
                                    icon: Icons.schedule,
                                    text: _formatDate(history.createdAt),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF627D98),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class EngineeringReportPage extends StatelessWidget {
  final AnalysisHistoryEntity history;
  final Aircraft aircraft;
  final Environment environment;
  final AnalysisResult result;

  const EngineeringReportPage({
    super.key,
    required this.history,
    required this.aircraft,
    required this.environment,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Mühendislik Raporu'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _ReportSection(
                    title: 'Araç Bilgileri',
                    icon: Icons.flight_outlined,
                    items: [
                      _ReportItem('Araç Adı', aircraft.name),
                      _ReportItem('Araç Türü', aircraft.type),
                      _ReportItem('Ağırlık', _unit(aircraft.weightKg, 'kg')),
                      _ReportItem(
                        'Kanat Alanı',
                        _unit(aircraft.wingAreaM2, 'm²'),
                      ),
                      _ReportItem(
                        'Kanat Açıklığı',
                        _unit(aircraft.wingSpanM, 'm'),
                      ),
                      _ReportItem(
                        'Motor Sayısı',
                        aircraft.motorCount.toString(),
                      ),
                      _ReportItem(
                        'Kurulu Motor Gücü',
                        _unit(aircraft.motorPowerW, 'W'),
                      ),
                      _ReportItem(
                        'Batarya',
                        '${aircraft.batteryType} '
                            '${aircraft.batteryCellCount}S '
                            '${_format(aircraft.batteryCapacityMah)} mAh',
                      ),
                    ],
                  ),
                  _ReportSection(
                    title: 'Çevre Koşulları',
                    icon: Icons.public_outlined,
                    items: [
                      _ReportItem('İrtifa', _unit(environment.altitudeM, 'm')),
                      _ReportItem(
                        'Sıcaklık',
                        _unit(environment.temperatureC, '°C'),
                      ),
                      _ReportItem(
                        'Basınç',
                        _unit(environment.pressureHpa, 'hPa'),
                      ),
                      _ReportItem(
                        'Nem',
                        _unit(environment.humidityPercent, '%'),
                      ),
                      _ReportItem(
                        'Rüzgâr Hızı',
                        _unit(environment.windSpeedKmh, 'km/sa'),
                      ),
                      _ReportItem('Rüzgâr Yönü', environment.windDirection),
                      _ReportItem(
                        'Yoğunluk İrtifası',
                        _unit(result.densityAltitudeM, 'm'),
                      ),
                      _ReportItem('Atmosfer Durumu', result.atmosphereStatus),
                    ],
                  ),
                  _ReportSection(
                    title: 'Temel Aerodinamik',
                    icon: Icons.air_outlined,
                    items: [
                      _ReportItem('Kaldırma', _unit(result.liftN, 'N')),
                      _ReportItem('Sürükleme', _unit(result.dragN, 'N')),
                      _ReportItem(
                        'Kanat Yüklemesi',
                        _unit(result.wingLoading, 'N/m²'),
                      ),
                      _ReportItem(
                        'Stall Hızı',
                        _unit(result.stallSpeed, 'm/s'),
                      ),
                      _ReportItem(
                        'Aspect Ratio',
                        _formatValue(result.aspectRatio),
                      ),
                      _ReportItem(
                        'L/D Oranı',
                        _formatValue(result.liftToDragRatio),
                      ),
                      _ReportItem(
                        'Sürükleme Katsayısı',
                        _formatValue(result.dragCoefficient),
                      ),
                      _ReportItem(
                        'Aerodinamik Durum',
                        result.isCruiseAerodynamicallyValid
                            ? 'Uygun'
                            : 'Uygun Değil',
                      ),
                    ],
                  ),
                  _ReportSection(
                    title: 'Güç ve İtki',
                    icon: Icons.bolt_outlined,
                    items: [
                      _ReportItem(
                        'Tahmini Toplam İtki',
                        _unit(result.estimatedThrustN, 'N'),
                      ),
                      _ReportItem(
                        'İtki / Ağırlık',
                        _formatValue(result.thrustToWeight),
                      ),
                      _ReportItem(
                        'Güç / Ağırlık',
                        _unit(result.powerToWeight, 'W/kg'),
                      ),
                      _ReportItem(
                        'Ortalama Görev Gücü',
                        _unit(result.averageMissionPowerW, 'W'),
                      ),
                      _ReportItem(
                        'Tepe Görev Gücü',
                        _unit(result.peakMissionPowerW, 'W'),
                      ),
                      _ReportItem(
                        'Kurulu Güç Rezervi',
                        _unit(result.installedPowerReserveW, 'W'),
                      ),
                      _ReportItem(
                        'Güç Rezervi',
                        _unit(result.installedPowerReservePercent, '%'),
                      ),
                      _ReportItem(
                        'Propulsion Durumu',
                        result.propulsionSystemStatus,
                      ),
                    ],
                  ),
                  _ReportSection(
                    title: 'Enerji ve Batarya',
                    icon: Icons.battery_charging_full_outlined,
                    items: [
                      _ReportItem(
                        'Nominal Enerji',
                        _unit(result.nominalBatteryEnergyWh, 'Wh'),
                      ),
                      _ReportItem(
                        'Kullanılabilir Enerji',
                        _unit(result.usableBatteryEnergyWh, 'Wh'),
                      ),
                      _ReportItem(
                        'Tahmini Uçuş Süresi',
                        _unit(result.estimatedFlightTime, 'dk'),
                      ),
                      _ReportItem(
                        'Ortalama Akım',
                        _unit(result.averageBatteryCurrentA, 'A'),
                      ),
                      _ReportItem(
                        'Tepe Akım',
                        _unit(result.peakBatteryCurrentA, 'A'),
                      ),
                      _ReportItem(
                        'Ortalama C-Rate',
                        _formatValue(result.averageCRate),
                      ),
                      _ReportItem(
                        'Tepe C-Rate',
                        _formatValue(result.peakCRate),
                      ),
                      _ReportItem('Batarya Durumu', result.batterySystemStatus),
                    ],
                  ),
                  _ReportSection(
                    title: 'Uçuş Performansı',
                    icon: Icons.trending_up_outlined,
                    items: [
                      _ReportItem(
                        'Tırmanış Oranı',
                        _unit(result.climbPerformance.rateOfClimbMs, 'm/s'),
                      ),
                      _ReportItem(
                        'Tırmanış Açısı',
                        _unit(result.climbPerformance.climbAngleDeg, '°'),
                      ),
                      _ReportItem(
                        'Havada Kalış',
                        _unit(result.enduranceRange.enduranceMinutes, 'dk'),
                      ),
                      _ReportItem(
                        'Tahmini Menzil',
                        _unit(result.enduranceRange.windAdjustedRangeKm, 'km'),
                      ),
                      _ReportItem(
                        'En İyi Süzülüş Hızı',
                        _unit(result.glidePerformance.bestGlideSpeedMs, 'm/s'),
                      ),
                      _ReportItem(
                        'Süzülüş Oranı',
                        _formatValue(result.glidePerformance.bestGlideRatio),
                      ),
                      _ReportItem('CG Durumu', result.stability.status),
                      _ReportItem('Uçuş Zarfı', result.flightEnvelope.status),
                    ],
                  ),
                  _buildScoreSection(),
                  _buildRecommendationSection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D91),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AeroLab Mühendislik Analiz Raporu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aircraft.name,
                style: const TextStyle(color: Color(0xFFD9E8FF), fontSize: 17),
              ),
            ],
          ),
          Text(
            _formatDate(history.createdAt),
            style: const TextStyle(color: Color(0xFFD9E8FF), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return _ReportSection(
      title: 'Skorlar ve Risk',
      icon: Icons.assessment_outlined,
      items: [
        _ReportItem(
          'Aerodinamik Skor',
          result.aerodynamicScore?.toString() ?? 'Uygulanamaz',
        ),
        _ReportItem('Propulsion Skoru', result.propulsionScore.toString()),
        _ReportItem('Enerji Skoru', result.energyScore.toString()),
        _ReportItem('Batarya Skoru', result.batteryScore.toString()),
        _ReportItem('Genel Skor', result.overallScore.toString()),
        _ReportItem('Risk Skoru', result.riskScore.toString()),
        _ReportItem('Genel Durum', result.status),
        _ReportItem('Batarya Güvenliği', result.batteryScoreStatus),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC6D4EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.engineering_outlined, color: Color(0xFF0B3D91)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mühendislik Değerlendirmesi ve Öneriler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.recommendation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF243B53),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            result.batteryRecommendationTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            result.batteryRecommendationMessage,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFF243B53),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatValue(double value) {
    if (!value.isFinite) {
      return 'Uygulanamaz';
    }

    return value.toStringAsFixed(2);
  }

  static String _format(double value) {
    if (!value.isFinite) {
      return 'Uygulanamaz';
    }

    return value.toStringAsFixed(1);
  }

  static String _unit(double value, String unit) {
    if (!value.isFinite) {
      return 'Uygulanamaz';
    }

    return '${value.toStringAsFixed(2)} $unit';
  }

  static String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ReportItem> items;

  const _ReportSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0B3D91)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              final itemWidth =
                  (constraints.maxWidth - ((columns - 1) * 12)) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: itemWidth,
                      child: _ReportValueTile(item: item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportValueTile extends StatelessWidget {
  final _ReportItem item;

  const _ReportValueTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF627D98)),
          ),
          const SizedBox(height: 5),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF102A43),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  final String label;
  final String value;

  const _ReportItem(this.label, this.value);
}

class _ReportMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReportMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF627D98)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF627D98)),
        ),
      ],
    );
  }
}

class _ReportMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ReportMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 68, color: const Color(0xFF829AB1)),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102A43),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF627D98)),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
