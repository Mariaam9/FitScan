import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../models/analysis_result_model.dart';

class RecentSessionTile extends StatelessWidget {
  final SessionModel session;
  const RecentSessionTile({super.key, required this.session});

  Color _color() {
    switch (session.type) {
      case AnalysisType.pose:
        return AppColors.poseColor;
      case AnalysisType.object:
        return AppColors.objectColor;
      case AnalysisType.labeling:
        return AppColors.labelColor;
      case AnalysisType.face:
        return AppColors.faceColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final score = session.displayScore;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(session.type.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.type.label,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  DateFormat('dd MMM yyyy · HH:mm', 'fr').format(session.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}
