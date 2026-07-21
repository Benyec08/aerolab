import '../../features/analysis/models/aircraft.dart';
import '../../features/analysis/models/analysis_result.dart';
import '../../features/analysis/models/environment.dart';
import '../entities/analysis_history_entity.dart';
import '../mappers/analysis_history_mapper.dart';
import '../repositories/analysis_history_repository.dart';

class AnalysisHistoryService {
  final AnalysisHistoryRepository _repository;
  final AnalysisHistoryMapper _mapper;

  AnalysisHistoryService({
    AnalysisHistoryRepository? repository,
    AnalysisHistoryMapper? mapper,
  }) : _repository = repository ?? AnalysisHistoryRepository(),
       _mapper = mapper ?? const AnalysisHistoryMapper();

  List<AnalysisHistoryEntity> getAllAnalyses() {
    return _repository.getAll();
  }

  AnalysisHistoryEntity? getAnalysisById(String id) {
    return _repository.getById(id);
  }

  int get analysisCount => _repository.count;

  Future<AnalysisHistoryEntity> saveAnalysis({
    required Aircraft aircraft,
    required Environment environment,
    required AnalysisResult result,
  }) async {
    final history = _mapper.toEntity(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await _repository.add(history);

    return history;
  }

  Aircraft restoreAircraft(AnalysisHistoryEntity history) {
    return _mapper.restoreAircraft(history);
  }

  Environment restoreEnvironment(AnalysisHistoryEntity history) {
    return _mapper.restoreEnvironment(history);
  }

  AnalysisResult restoreResult(AnalysisHistoryEntity history) {
    return _mapper.restoreResult(history);
  }

  Future<void> deleteAnalysis(String id) async {
    await _repository.delete(id);
  }

  Future<void> clearHistory() async {
    await _repository.clearAll();
  }
}
