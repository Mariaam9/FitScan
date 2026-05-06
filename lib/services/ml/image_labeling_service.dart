import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../models/analysis_result_model.dart';

class ImageLabelingService {
  ImageLabeler? _labeler;

  static const _sportLabels = <String, String>{
    'running': 'Course à pied',
    'jogging': 'Course à pied',
    'yoga': 'Yoga',
    'weightlifting': 'Musculation',
    'weight training': 'Musculation',
    'cycling': 'Cyclisme',
    'swimming': 'Natation',
    'boxing': 'Boxe',
    'stretching': 'Étirements',
    'jumping': 'Saut',
    'push-up': 'Pompes',
    'squat': 'Squat',
    'pilates': 'Pilates',
    'crossfit': 'CrossFit',
    'martial arts': 'Arts martiaux',
    'basketball': 'Basketball',
    'football': 'Football',
    'tennis': 'Tennis',
    'gymnastics': 'Gymnastique',
    'dance': 'Danse',
    'fitness': 'Fitness',
    'exercise': 'Exercice général',
    'sport': 'Sport',
    'athlete': 'Athlétisme',
  };

  static const _exerciseSuggestions = <String, List<String>>{
    'Course à pied': [
      'Intervalles 30s sprint / 1min marche',
      'Fartlek 20 minutes',
      'Course longue 45 min en zone 2',
    ],
    'Yoga': [
      'Salutation au soleil (3 séries)',
      'Posture du guerrier I & II',
      'Séquence équilibre sur un pied',
    ],
    'Musculation': [
      'Squat 4x10',
      'Développé couché 4x8',
      'Tractions 3x max',
      'Soulevé de terre 3x5',
    ],
    'Cyclisme': [
      'Sortie endurance 1h',
      'Intervalles en côte',
      'Récupération active à faible intensité',
    ],
    'Boxe': [
      'Shadowboxing 3x3 min',
      'Corde à sauter 10 min',
      'Combinaisons sur sac 4x2 min',
    ],
    'Étirements': [
      'Routine mobilité matinale 15 min',
      'Stretching post-entraînement',
      'Foam rolling 10 min',
    ],
    'Fitness': [
      'HIIT 20 min',
      'Circuit training 5 exercices',
      'Tabata 8 rounds',
    ],
  };

  Future<void> _init() async {
    _labeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  Future<LabelResult> analyze(String imagePath) async {
    if (kIsWeb) return _simulateResult();

    await _init();
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _labeler!.processImage(inputImage);

    if (labels.isEmpty) {
      return const LabelResult(
        topLabel: 'Non reconnu',
        confidence: 0,
        allLabels: [],
        suggestedExercises: [
          'Aucune activité reconnue — réessayez avec une image plus nette',
        ],
      );
    }

    // Cherche un label sportif connu
    String topLabel = 'Activité physique';
    double topConf = labels.first.confidence;

    for (final lbl in labels) {
      final lower = lbl.label.toLowerCase();
      for (final k in _sportLabels.keys) {
        if (lower.contains(k)) {
          topLabel = _sportLabels[k]!;
          topConf = lbl.confidence;
          break;
        }
      }
      if (topLabel != 'Activité physique') break;
    }

    final allLabels = labels
        .take(6)
        .map(
          (l) => {
            'label': _sportLabels[l.label.toLowerCase()] ?? l.label,
            'confidence': l.confidence,
          },
        )
        .toList();

    final suggestions =
        _exerciseSuggestions[topLabel] ??
        [
          'Continuez votre activité à un rythme adapté',
          'Pensez à vous hydrater régulièrement',
        ];

    return LabelResult(
      topLabel: topLabel,
      confidence: topConf,
      allLabels: allLabels,
      suggestedExercises: suggestions,
    );
  }

  LabelResult _simulateResult() {
    final options = [
      'Course à pied',
      'Yoga',
      'Musculation',
      'Fitness',
      'Cyclisme',
    ];
    final rng = math.Random();
    final top = options[rng.nextInt(options.length)];
    return LabelResult(
      topLabel: top,
      confidence: 0.70 + rng.nextDouble() * 0.25,
      allLabels: [
        {'label': top, 'confidence': 0.85},
        {'label': 'Sport', 'confidence': 0.65},
        {'label': 'Activité physique', 'confidence': 0.55},
      ],
      suggestedExercises:
          _exerciseSuggestions[top] ?? ['Continuez votre entraînement !'],
    );
  }

  Future<void> dispose() async => await _labeler?.close();
}
