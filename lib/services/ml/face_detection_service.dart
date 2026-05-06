import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../models/analysis_result_model.dart';

class FaceDetectionService {
  FaceDetector? _detector;

  Future<void> _init() async {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,   // smiling, eyes open
        enableContours: false,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      ),
    );
  }

  Future<FaceResult> analyze(String imagePath) async {
    if (kIsWeb) return _simulateResult();

    await _init();
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _detector!.processImage(inputImage);

    if (faces.isEmpty) {
      return const FaceResult(
        rpeScore: 5,
        effortLabel: 'Non détecté',
        expressions: ['Aucun visage détecté'],
        fatigueAdvice: 'Assurez-vous que votre visage est bien visible et éclairé',
        highFatigueAlert: false,
        smileProb: 0,
        eyesOpenProb: 1,
      );
    }

    final face = faces.first;
    final smileProb = face.smilingProbability ?? 0.5;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final eyesOpen = (leftEyeOpen + rightEyeOpen) / 2;

    final expressions = _detectExpressions(smileProb, eyesOpen);
    final rpe = _estimateRPE(smileProb, eyesOpen);
    final label = _rpeLabel(rpe);
    final advice = _buildAdvice(rpe, expressions);
    final alert = rpe >= 9;

    return FaceResult(
      rpeScore: rpe,
      effortLabel: label,
      expressions: expressions,
      fatigueAdvice: advice,
      highFatigueAlert: alert,
      smileProb: smileProb,
      eyesOpenProb: eyesOpen,
    );
  }

  List<String> _detectExpressions(double smile, double eyes) {
    final list = <String>[];
    if (smile > 0.7) list.add('Sourire — effort confortable');
    if (smile < 0.2) list.add('Grimace — effort intense');
    if (eyes < 0.4) list.add('Yeux mi-clos — fatigue détectée');
    if (eyes > 0.9 && smile > 0.5) list.add('Détendu — faible intensité');
    if (list.isEmpty) list.add('Expression neutre — effort modéré');
    return list;
  }

  /// Estime le score RPE (1–10) à partir du sourire et de l'ouverture des yeux
  int _estimateRPE(double smile, double eyesOpen) {
    // Plus le sourire est bas + yeux fermés → RPE élevé
    double effort = 1.0 - (smile * 0.5 + eyesOpen * 0.5);
    int rpe = (effort * 9 + 1).round();
    return rpe.clamp(1, 10);
  }

  String _rpeLabel(int rpe) {
    if (rpe <= 3) return 'Très facile';
    if (rpe <= 5) return 'Modéré';
    if (rpe <= 7) return 'Difficile';
    if (rpe <= 9) return 'Très difficile';
    return 'Maximum — Effort extrême';
  }

  String _buildAdvice(int rpe, List<String> expressions) {
    if (rpe >= 9) {
      return '⚠️ Fatigue extrême détectée ! Prenez une pause immédiatement et hydratez-vous.';
    }
    if (rpe >= 7) {
      return 'Effort intense — vérifiez votre respiration. Ralentissez si nécessaire.';
    }
    if (rpe >= 5) {
      return 'Bonne intensité ! Maintenez ce rythme pour progresser.';
    }
    if (rpe >= 3) {
      return 'Effort léger — vous pouvez augmenter l\'intensité si vous le souhaitez.';
    }
    return 'Très faible effort — idéal pour la récupération active.';
  }

  FaceResult _simulateResult() {
    final rng = math.Random();
    final smile = rng.nextDouble();
    final eyes = 0.3 + rng.nextDouble() * 0.7;
    final rpe = (1.0 - (smile * 0.5 + eyes * 0.5)) * 9 + 1;
    final rpeInt = rpe.round().clamp(1, 10);
    final expressions = _detectExpressions(smile, eyes);

    return FaceResult(
      rpeScore: rpeInt,
      effortLabel: _rpeLabel(rpeInt),
      expressions: expressions,
      fatigueAdvice: _buildAdvice(rpeInt, expressions),
      highFatigueAlert: rpeInt >= 9,
      smileProb: smile,
      eyesOpenProb: eyes,
    );
  }

  Future<void> dispose() async => await _detector?.close();
}
