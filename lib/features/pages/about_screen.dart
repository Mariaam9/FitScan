import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _services = [
    {'emoji': '🧘', 'name': 'Pose Detection', 'desc': 'Détecte les erreurs de posture, analyse les angles articulaires et attribue un score d\'exécution 0–100.', 'color': AppColors.poseColor},
    {'emoji': '🏋️', 'name': 'Object Detection', 'desc': 'Identifie l\'équipement sportif présent (haltères, tapis, barre…) avec bounding boxes et conseils adaptés.', 'color': AppColors.objectColor},
    {'emoji': '🏃', 'name': 'Image Labeling', 'desc': 'Reconnaît automatiquement le type d\'exercice (yoga, musculation, course…) depuis une simple photo.', 'color': AppColors.labelColor},
    {'emoji': '😓', 'name': 'Face Detection', 'desc': 'Estime l\'intensité perçue (RPE 1–10) via l\'analyse des expressions faciales : sourire, grimace, yeux fermés.', 'color': AppColors.faceColor},
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'À propos',
        onMenuPressed: () => scaffoldState.openDrawer(),
        showHelpButton: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text('FitScan', style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const Text('Coach Fitness Intelligent', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('v1.0.0', style: TextStyle(color: Colors.white60, fontFamily: 'Poppins', fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('À propos de l\'application', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'FitScan est une application mobile Flutter intelligente qui accompagne l\'utilisateur dans ses séances sportives en analysant sa posture, reconnaissant son activité, détectant son équipement et évaluant son niveau d\'effort via ses expressions faciales.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 28),
                Text('4 Services ML Kit utilisés', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                ..._services.asMap().entries.map((entry) {
                  final s = entry.value;
                  final color = s['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(s['desc'] as String, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: entry.key * 100)).slideY(begin: 0.2).fade();
                }),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}