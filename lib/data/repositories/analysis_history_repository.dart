import 'package:hive_ce/hive_ce.dart';

import '../entities/analysis_history_entity.dart';
import '../hive/hive_boxes.dart';

class AnalysisHistoryRepository {
  Box<AnalysisHistoryEntity> get _box {
    if (!Hive.isBoxOpen(HiveBoxes.analysisHistory)) {
      throw StateError('Analiz geçmişi Hive kutusu henüz açılmadı.');
    }

    return Hive.box<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);
  }

  List<AnalysisHistoryEntity> getAll() {
    final history = _box.values.toList();

    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return history;
  }

  AnalysisHistoryEntity? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(AnalysisHistoryEntity history) async {
    await _box.put(history.id, history);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool contains(String id) {
    return _box.containsKey(id);
  }

  int get count {
    return _box.length;
  }
}
