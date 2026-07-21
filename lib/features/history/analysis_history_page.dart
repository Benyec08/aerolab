import 'package:flutter/material.dart';

import '../../data/entities/analysis_history_entity.dart';
import '../../data/services/analysis_history_service.dart';
import '../analysis/analysis_result_page.dart';

class AnalysisHistoryPage extends StatefulWidget {
  final AnalysisHistoryService? historyService;

  const AnalysisHistoryPage({super.key, this.historyService});

  @override
  State<AnalysisHistoryPage> createState() => _AnalysisHistoryPageState();
}

class _AnalysisHistoryPageState extends State<AnalysisHistoryPage> {
  late final AnalysisHistoryService _historyService;
  List<AnalysisHistoryEntity> _history = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? AnalysisHistoryService();
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final history = _historyService.getAllAnalyses();

      setState(() {
        _history = history;
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _history = const [];
        _errorMessage = 'Analiz geçmişi yüklenemedi: $error';
      });
    }
  }

  Future<void> _openHistory(AnalysisHistoryEntity history) async {
    try {
      final result = _historyService.restoreResult(history);

      if (!mounted) {
        return;
      }

      final returnToDashboard = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => AnalysisResultPage(result: result)),
      );

      if (returnToDashboard == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analiz sonucu açılamadı: $error')),
      );
    }
  }

  Future<void> _deleteHistory(AnalysisHistoryEntity history) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Analizi sil'),
          content: Text(
            '${history.aircraftName} için kaydedilen analiz silinsin mi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _historyService.deleteAnalysis(history.id);

      if (!mounted) {
        return;
      }

      _loadHistory();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Analiz kaydı silindi.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analiz kaydı silinemedi: $error')),
      );
    }
  }

  Future<void> _clearHistory() async {
    if (_history.isEmpty) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tüm geçmişi temizle'),
          content: const Text(
            'Bütün analiz kayıtları kalıcı olarak silinecek. Devam edilsin mi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Tümünü Sil'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    try {
      await _historyService.clearHistory();

      if (!mounted) {
        return;
      }

      _loadHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analiz geçmişi temizlendi.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analiz geçmişi temizlenemedi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Analiz Geçmişi'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Tüm geçmişi temizle',
            onPressed: _history.isEmpty ? null : _clearHistory,
            icon: const Icon(Icons.delete_sweep_outlined),
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
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Geçmiş yüklenemedi',
        message: _errorMessage!,
        actionLabel: 'Tekrar Dene',
        onAction: _loadHistory,
      );
    }

    if (_history.isEmpty) {
      return const _MessageState(
        icon: Icons.history,
        title: 'Henüz analiz kaydı yok',
        message:
            'Tamamladığınız analizler otomatik olarak burada listelenecek.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_history.length} kayıtlı analiz',
          style: const TextStyle(fontSize: 15, color: Color(0xFF627D98)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _history.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final history = _history[index];

              return _HistoryCard(
                history: history,
                onOpen: () => _openHistory(history),
                onDelete: () => _deleteHistory(history),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AnalysisHistoryEntity history;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.history,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
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
                  Icons.analytics_outlined,
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
                        _HistoryMeta(
                          icon: Icons.flight_outlined,
                          text: history.aircraftType,
                        ),
                        _HistoryMeta(
                          icon: Icons.schedule,
                          text: _formatDate(history.createdAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Analizi sil',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF627D98)),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _HistoryMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HistoryMeta({required this.icon, required this.text});

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

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
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
