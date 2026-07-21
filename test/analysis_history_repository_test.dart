import 'dart:io';

import 'package:aerolab/data/entities/analysis_history_entity.dart';
import 'package:aerolab/data/hive/hive_boxes.dart';
import 'package:aerolab/data/repositories/analysis_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDirectory;
  late AnalysisHistoryRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'aerolab_analysis_history_repository_test_',
    );

    Hive.init(tempDirectory.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AnalysisHistoryEntityAdapter());
    }

    await Hive.openBox<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);

    repository = AnalysisHistoryRepository();
  });

  tearDown(() async {
    await Hive.close();

    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  AnalysisHistoryEntity createHistory({
    required String id,
    required DateTime createdAt,
    required String aircraftName,
  }) {
    return AnalysisHistoryEntity(
      id: id,
      createdAt: createdAt,
      aircraftName: aircraftName,
      aircraftType: 'Sabit Kanat',
      aircraftDataJson: '{"name":"$aircraftName"}',
      environmentDataJson: '{"altitudeM":0}',
      resultDataJson: '{"overallScore":80}',
    );
  }

  test('adds and retrieves an analysis history record by id', () async {
    final history = createHistory(
      id: 'history-1',
      createdAt: DateTime(2026, 7, 21, 18, 30),
      aircraftName: 'Test Uçağı',
    );

    await repository.add(history);

    expect(repository.count, 1);
    expect(repository.contains(history.id), isTrue);
    expect(repository.getById(history.id)?.aircraftName, 'Test Uçağı');
  });

  test('returns records from newest to oldest', () async {
    final olderHistory = createHistory(
      id: 'history-old',
      createdAt: DateTime(2026, 7, 20),
      aircraftName: 'Eski Analiz',
    );

    final newerHistory = createHistory(
      id: 'history-new',
      createdAt: DateTime(2026, 7, 21),
      aircraftName: 'Yeni Analiz',
    );

    await repository.add(olderHistory);
    await repository.add(newerHistory);

    final history = repository.getAll();

    expect(history, hasLength(2));
    expect(history.first.id, 'history-new');
    expect(history.last.id, 'history-old');
  });

  test('deletes a single analysis history record', () async {
    final firstHistory = createHistory(
      id: 'history-1',
      createdAt: DateTime(2026, 7, 20),
      aircraftName: 'Birinci Analiz',
    );

    final secondHistory = createHistory(
      id: 'history-2',
      createdAt: DateTime(2026, 7, 21),
      aircraftName: 'İkinci Analiz',
    );

    await repository.add(firstHistory);
    await repository.add(secondHistory);

    await repository.delete(firstHistory.id);

    expect(repository.count, 1);
    expect(repository.contains(firstHistory.id), isFalse);
    expect(repository.contains(secondHistory.id), isTrue);
  });

  test('clears all analysis history records', () async {
    await repository.add(
      createHistory(
        id: 'history-1',
        createdAt: DateTime(2026, 7, 20),
        aircraftName: 'Birinci Analiz',
      ),
    );

    await repository.add(
      createHistory(
        id: 'history-2',
        createdAt: DateTime(2026, 7, 21),
        aircraftName: 'İkinci Analiz',
      ),
    );

    await repository.clearAll();

    expect(repository.count, 0);
    expect(repository.getAll(), isEmpty);
  });

  test('generated history ids are unique', () {
    final firstId = AnalysisHistoryEntity.generateUniqueId();
    final secondId = AnalysisHistoryEntity.generateUniqueId();

    expect(firstId, isNot(secondId));
  });
}
