import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../services/session_service.dart';
import '../../services/auth_service.dart';
import '../../models/analysis_result_model.dart';
import '../widgets/common/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();
  
  List<SessionModel> _sessions = [];
  AnalysisType? _filter;
  bool _isLoading = true;

  static const _filters = [null, AnalysisType.pose, AnalysisType.object, AnalysisType.labeling, AnalysisType.face];
  static const _filterLabels = ['Tous', '🧘 Pose', '🏋️ Object', '🏃 Label', '😓 Face'];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final sessions = await _sessionService.getAllSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<SessionModel> get _filteredSessions {
    if (_filter == null) return _sessions;
    return _sessions.where((s) => s.type == _filter).toList();
  }

  Future<void> _deleteSession(String sessionId) async {
    await _sessionService.deleteSession(sessionId);
    await _loadSessions();
  }

  Future<void> _deleteAllSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer tout ?'),
        content: const Text('Toutes vos séances seront définitivement supprimées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await _sessionService.deleteAllSessions();
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Historique',
        onMenuPressed: () => scaffoldState.openDrawer(),
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep_rounded), onPressed: _deleteAllSessions),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _filter == _filters[i];
                return ChoiceChip(
                  label: Text(_filterLabels[i], style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = _filters[i]),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  side: BorderSide(color: selected ? AppColors.primary : Colors.transparent),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSessions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📂', style: TextStyle(fontSize: 52)),
                            SizedBox(height: 16),
                            Text('Aucune séance', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('Lancez une analyse pour commencer !'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final s = _filteredSessions[i];
                          return _SessionCard(
                            session: s,
                            onDelete: () => _deleteSession(s.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onDelete;
  const _SessionCard({required this.session, required this.onDelete});

  Color _color() {
    switch (session.type) {
      case AnalysisType.pose: return AppColors.poseColor;
      case AnalysisType.object: return AppColors.objectColor;
      case AnalysisType.labeling: return AppColors.labelColor;
      case AnalysisType.face: return AppColors.faceColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(session.type.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.type.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text(DateFormat('EEE dd MMM · HH:mm', 'fr').format(session.date), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text('${session.displayScore}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18), color: AppColors.error.withOpacity(0.6), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}