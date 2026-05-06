import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/app_colors.dart';
import '../../models/analysis_result_model.dart';
import '../widgets/common/custom_app_bar.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const ResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'pose';
    final result = data['result'];
    final analysisType = AnalysisType.fromString(type);
    return Scaffold(
      appBar: CustomAppBar(
        title: '${analysisType.emoji} Résultats',
        showBackButton: true,
        onClose: () => context.go('/home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _gradient(analysisType),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(analysisType.emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(
                    analysisType.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    analysisType.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9)).fade(),

            const SizedBox(height: 24),

            // Résultat selon le type
            if (result is PoseResult) _PoseResultView(result: result),
            if (result is ObjectResult) _ObjectResultView(result: result),
            if (result is LabelResult) _LabelResultView(result: result),
            if (result is FaceResult) _FaceResultView(result: result),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              icon: const Icon(Icons.home_rounded),
              label: const Text('Retour à l\'accueil'),
              onPressed: () => context.go('/home'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _gradient(AnalysisType t) {
    switch (t) {
      case AnalysisType.pose: return AppColors.poseGradient;
      case AnalysisType.object: return AppColors.objectGradient;
      case AnalysisType.labeling: return AppColors.labelGradient;
      case AnalysisType.face: return AppColors.faceGradient;
    }
  }
}

// ── Pose ─────────────────────────────────────────────────────────
class _PoseResultView extends StatelessWidget {
  final PoseResult result;
  const _PoseResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircularPercentIndicator(
            radius: 70,
            lineWidth: 12,
            percent: result.score / 100,
            center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${result.score}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
              const Text('/100', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontFamily: 'Poppins')),
            ]),
            progressColor: result.score >= 80 ? AppColors.poseGood : AppColors.poseBad,
            backgroundColor: AppColors.poseColor.withOpacity(0.15),
            animation: true,
          ),
        ),
        const SizedBox(height: 20),
        if (result.errors.isNotEmpty) ...[
          Text('Erreurs détectées', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...result.errors.asMap().entries.map((e) => _ErrorTile(
                error: e.value,
                correction: result.corrections.length > e.key ? result.corrections[e.key] : '',
              )),
        ] else
          _SuccessBanner(),
        const SizedBox(height: 16),
        if (result.jointAngles.isNotEmpty) ...[
          Text('Angles articulaires', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: result.jointAngles.entries.map((e) => Chip(
              label: Text('${e.key}: ${e.value.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
              backgroundColor: AppColors.poseColor.withOpacity(0.1),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String error;
  final String correction;
  const _ErrorTile({required this.error, required this.correction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(error, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins'))),
        ]),
        if (correction.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(correction, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'))),
          ]),
        ],
      ]),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: const Row(children: [
        Icon(Icons.check_circle_rounded, color: AppColors.success),
        SizedBox(width: 10),
        Text('Posture parfaite ! Continue comme ça 💪',
            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      ]),
    );
  }
}

// ── Object ───────────────────────────────────────────────────────
class _ObjectResultView extends StatelessWidget {
  final ObjectResult result;
  const _ObjectResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipements détectés (${result.objects.length})',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (result.objects.isEmpty)
          const Text('Aucun équipement sportif reconnu'),
        ...result.objects.map((obj) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.objectColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.objectColor.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.fitness_center_rounded, color: AppColors.objectColor),
            const SizedBox(width: 10),
            Expanded(child: Text(obj.label, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
            Text('${(obj.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.objectColor, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ]),
        )),
        if (result.trainingTips.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Conseils d\'entraînement', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...result.trainingTips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.tips_and_updates_rounded, color: AppColors.objectColor, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'))),
            ]),
          )),
        ],
      ],
    );
  }
}

// ── Label ────────────────────────────────────────────────────────
class _LabelResultView extends StatelessWidget {
  final LabelResult result;
  const _LabelResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.labelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.labelColor.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text(result.topLabel,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text('Confiance : ${(result.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: AppColors.labelColor, fontFamily: 'Poppins')),
          ]),
        ),
        const SizedBox(height: 16),
        Text('Exercices suggérés', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...result.suggestedExercises.map((ex) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.play_circle_outline_rounded, color: AppColors.labelColor, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(ex, style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'))),
          ]),
        )),
      ],
    );
  }
}

// ── Face ─────────────────────────────────────────────────────────
class _FaceResultView extends StatelessWidget {
  final FaceResult result;
  const _FaceResultView({required this.result});

  Color _rpeColor() {
    if (result.rpeScore <= 3) return AppColors.effortLow;
    if (result.rpeScore <= 5) return AppColors.effortMed;
    if (result.rpeScore <= 7) return AppColors.effortHigh;
    return AppColors.effortMax;
  }

  @override
  Widget build(BuildContext context) {
    final color = _rpeColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.highFatigueAlert)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.warning_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Expanded(
                child: Text('⚠️ Fatigue extrême détectée ! Reposez-vous.',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              ),
            ]),
          ),
        Center(
          child: CircularPercentIndicator(
            radius: 70,
            lineWidth: 12,
            percent: result.rpeScore / 10,
            center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${result.rpeScore}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
              const Text('/10 RPE', style: TextStyle(fontSize: 11, fontFamily: 'Poppins')),
            ]),
            progressColor: color,
            backgroundColor: color.withOpacity(0.15),
            animation: true,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(result.effortLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
        ),
        const SizedBox(height: 20),
        Text('Expressions faciales', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...result.expressions.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.face_rounded, size: 16, color: AppColors.faceColor),
            const SizedBox(width: 8),
            Text(e, style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
          ]),
        )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(result.fatigueAdvice,
              style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}