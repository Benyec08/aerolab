import 'package:hive_ce/hive_ce.dart';

part 'analysis_history_entity.g.dart';

@HiveType(typeId: 1)
class AnalysisHistoryEntity {
  static int _lastGeneratedIdMicroseconds = 0;

  static String generateUniqueId() {
    final currentMicroseconds = DateTime.now().microsecondsSinceEpoch;

    if (currentMicroseconds <= _lastGeneratedIdMicroseconds) {
      _lastGeneratedIdMicroseconds++;
    } else {
      _lastGeneratedIdMicroseconds = currentMicroseconds;
    }

    return _lastGeneratedIdMicroseconds.toString();
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final String aircraftName;

  @HiveField(3)
  final String aircraftType;

  @HiveField(4)
  final String aircraftDataJson;

  @HiveField(5)
  final String environmentDataJson;

  @HiveField(6)
  final String resultDataJson;

  @HiveField(7, defaultValue: 1)
  final int dataVersion;

  const AnalysisHistoryEntity({
    required this.id,
    required this.createdAt,
    required this.aircraftName,
    required this.aircraftType,
    required this.aircraftDataJson,
    required this.environmentDataJson,
    required this.resultDataJson,
    this.dataVersion = 1,
  });

  factory AnalysisHistoryEntity.create({
    required String aircraftName,
    required String aircraftType,
    required String aircraftDataJson,
    required String environmentDataJson,
    required String resultDataJson,
  }) {
    return AnalysisHistoryEntity(
      id: generateUniqueId(),
      createdAt: DateTime.now(),
      aircraftName: aircraftName,
      aircraftType: aircraftType,
      aircraftDataJson: aircraftDataJson,
      environmentDataJson: environmentDataJson,
      resultDataJson: resultDataJson,
    );
  }
}
