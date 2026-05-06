import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as mlkit;
import '../../models/analysis_result_model.dart';

class ObjectDetectionService {
  mlkit.ObjectDetector? _detector;

  static const _sportKeywords = [
    'dumbbell',
    'barbell',
    'kettlebell',
    'ball',
    'mat',
    'yoga',
    'rope',
    'bicycle',
    'treadmill',
    'bench',
    'rack',
    'glove',
    'helmet',
    'racket',
    'weight',
    'fitness',
    'gym',
    'sport',
    'equipment',
  ];

  static const _translations = <String, String>{
    'dumbbell': 'Haltère',
    'barbell': 'Barre de musculation',
    'kettlebell': 'Kettlebell',
    'ball': 'Ballon',
    'mat': 'Tapis',
    'yoga': 'Tapis de yoga',
    'rope': 'Corde à sauter',
    'bicycle': 'Vélo',
    'treadmill': 'Tapis de course',
    'bench': 'Banc de musculation',
    'rack': 'Rack',
    'glove': 'Gant',
    'helmet': 'Casque',
    'racket': 'Raquette',
  };

  static const _tipsMap = <String, List<String>>{
    'Haltère': [
      'Commencez avec un poids que vous maîtrisez',
      'Garder les poignets neutres pour éviter les blessures',
      'Essayez le curl biceps, les élévations latérales',
    ],
    'Tapis': [
      'Idéal pour les étirements et le yoga',
      'Vérifiez que la surface est antidérapante',
      'Essayez les postures de planche et abdominaux',
    ],
    'Kettlebell': [
      'Le swing kettlebell sollicite tout le corps',
      'Maintenez le dos droit pendant les exercices',
    ],
    'Ballon': [
      'Excellent pour le gainage et l\'équilibre',
      'Essayez les squats avec ballon contre le mur',
    ],
    'Corde à sauter': [
      'Parfait pour le cardio — 10 min = 1 km de course',
      'Commencez par des séries de 30 secondes',
    ],
  };

  Future<void> _init() async {
    _detector ??= mlkit.ObjectDetector(
      options: mlkit.ObjectDetectorOptions(
        mode: mlkit.DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
  }

  Future<ObjectResult> analyze(String imagePath) async {
    if (kIsWeb) return _simulateResult();

    await _init();
    final inputImage = mlkit.InputImage.fromFilePath(imagePath);
    final detected = await _detector!.processImage(inputImage);

    final objects = <DetectedObject>[];
    for (final obj in detected) {
      for (final label in obj.labels) {
        // Vérification null-safe pour label.text
        final labelText = label.text;

        final isEquip = _sportKeywords.any(
          (kw) => labelText.toLowerCase().contains(kw),
        );
        if (!isEquip || label.confidence < 0.45) continue;

        final translated = _translate(labelText);
        if (!objects.any((o) => o.label == translated)) {
          final bb = obj.boundingBox;
          objects.add(
            DetectedObject(
              label: translated,
              confidence: label.confidence,
              boundingBox: {
                      'left': bb.left / 1000,
                      'top': bb.top / 1000,
                      'right': bb.right / 1000,
                      'bottom': bb.bottom / 1000,
                    },
            ),
          );
        }
      }
    }

    final tips = _buildTips(objects.map((o) => o.label).toList());

    return ObjectResult(objects: objects, trainingTips: tips);
  }

  String _translate(String raw) {
    final lower = raw.toLowerCase();
    for (final entry in _translations.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return raw;
  }

  List<String> _buildTips(List<String> labels) {
    final tips = <String>[];
    for (final label in labels) {
      final t = _tipsMap[label];
      if (t != null) tips.addAll(t);
    }
    if (tips.isEmpty) {
      tips.add(
        'Équipement détecté — consultez un coach pour des conseils adaptés',
      );
    }
    return tips.take(4).toList();
  }

  ObjectResult _simulateResult() {
    final rng = math.Random();
    final pool = ['Haltère', 'Tapis', 'Kettlebell', 'Ballon'];
    final count = 1 + rng.nextInt(2);
    final selected = (pool..shuffle()).take(count).toList();
    final objects = selected
        .map(
          (l) => DetectedObject(
            label: l,
            confidence: 0.65 + rng.nextDouble() * 0.3,
          ),
        )
        .toList();
    return ObjectResult(objects: objects, trainingTips: _buildTips(selected));
  }

  Future<void> dispose() async => await _detector?.close();
}
