import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../models/analysis_result_model.dart';

class PoseDetectionService {
  PoseDetector? _detector;

  Future<void> _init() async {
    _detector ??= PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.single,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  /// Analyse une image locale et retourne un PoseResult
  Future<PoseResult> analyze(String imagePath) async {
    if (kIsWeb) return _simulateResult();

    await _init();
    final inputImage = InputImage.fromFilePath(imagePath);
    final poses = await _detector!.processImage(inputImage);

    if (poses.isEmpty) {
      return const PoseResult(
        score: 0,
        errors: ['Aucune pose détectée — assurez-vous d\'être bien visible'],
        corrections: ['Tenez-vous face à la caméra, corps entier visible'],
        jointAngles: {},
      );
    }

    final pose = poses.first;
    final angles = _computeAngles(pose);
    final errors = _detectErrors(pose, angles);
    final corrections = _buildCorrections(errors);
    final score = _computeScore(errors, angles);

    return PoseResult(
      score: score,
      errors: errors,
      corrections: corrections,
      jointAngles: angles,
    );
  }

  // ── Calcul des angles articulaires ──────────────────────────
  Map<String, double> _computeAngles(Pose pose) {
    final angles = <String, double>{};

    final lKnee = _angle(
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.leftKnee],
      pose.landmarks[PoseLandmarkType.leftAnkle],
    );
    if (lKnee != null) angles['Genou gauche'] = lKnee;

    final rKnee = _angle(
      pose.landmarks[PoseLandmarkType.rightHip],
      pose.landmarks[PoseLandmarkType.rightKnee],
      pose.landmarks[PoseLandmarkType.rightAnkle],
    );
    if (rKnee != null) angles['Genou droit'] = rKnee;

    final lElbow = _angle(
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.leftElbow],
      pose.landmarks[PoseLandmarkType.leftWrist],
    );
    if (lElbow != null) angles['Coude gauche'] = lElbow;

    final rElbow = _angle(
      pose.landmarks[PoseLandmarkType.rightShoulder],
      pose.landmarks[PoseLandmarkType.rightElbow],
      pose.landmarks[PoseLandmarkType.rightWrist],
    );
    if (rElbow != null) angles['Coude droit'] = rElbow;

    final back = _backAngle(pose);
    if (back != null) angles['Dos'] = back;

    return angles;
  }

  double? _angle(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) {
    if (a == null || b == null || c == null) return null;
    if (a.likelihood < 0.5 || b.likelihood < 0.5 || c.likelihood < 0.5) {
      return null;
    }
    final rad = math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x);
    double angle = (rad * 180 / math.pi).abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  double? _backAngle(Pose pose) {
    final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lh = pose.landmarks[PoseLandmarkType.leftHip];
    if (ls == null || lh == null) return null;
    return (math.atan2(ls.x - lh.x, lh.y - ls.y) * 180 / math.pi).abs();
  }

  // ── Détection d'erreurs ──────────────────────────────────────
  List<String> _detectErrors(Pose pose, Map<String, double> angles) {
    final errors = <String>[];

    // Dos courbé
    final back = angles['Dos'];
    if (back != null && back > 20) {
      errors.add('Dos courbé (${back.toStringAsFixed(0)}°)');
    }

    // Asymétrie des genoux
    final lk = angles['Genou gauche'];
    final rk = angles['Genou droit'];
    if (lk != null && rk != null && (lk - rk).abs() > 25) {
      errors.add('Genoux asymétriques — déséquilibre du poids');
    }

    // Épaules
    final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (ls != null && rs != null && (ls.y - rs.y).abs() > 40) {
      errors.add('Épaules déséquilibrées');
    }

    // Hyperflexion des genoux
    if (lk != null && lk < 60) errors.add('Genou gauche trop fléchi');
    if (rk != null && rk < 60) errors.add('Genou droit trop fléchi');

    return errors;
  }

  List<String> _buildCorrections(List<String> errors) {
    const map = {
      'Dos courbé': 'Redresse le dos — contracte les abdominaux',
      'Genoux asymétriques': 'Répartis le poids uniformément sur les deux pieds',
      'Épaules déséquilibrées': 'Abaisse et recule les épaules',
      'Genou gauche trop fléchi': 'Réduis la flexion du genou gauche',
      'Genou droit trop fléchi': 'Réduis la flexion du genou droit',
    };
    return errors.map((e) {
      for (final k in map.keys) {
        if (e.contains(k)) return map[k]!;
      }
      return 'Corrige ta posture';
    }).toList();
  }

  int _computeScore(List<String> errors, Map<String, double> angles) {
    int score = 100;
    score -= errors.length * 20;
    return score.clamp(0, 100);
  }

  // ── Simulation Web ──────────────────────────────────────────
  PoseResult _simulateResult() {
    final rng = math.Random();
    final score = 60 + rng.nextInt(40);
    final errors = score < 80
        ? ['Dos légèrement courbé', 'Genoux asymétriques']
        : <String>[];
    return PoseResult(
      score: score,
      errors: errors,
      corrections: errors.isEmpty
          ? []
          : ['Redresse le dos', 'Répartis le poids uniformément'],
      jointAngles: {
        'Genou gauche': 85.0 + rng.nextDouble() * 20,
        'Genou droit': 90.0 + rng.nextDouble() * 20,
        'Dos': 10.0 + rng.nextDouble() * 15,
        'Coude gauche': 120.0 + rng.nextDouble() * 30,
      },
    );
  }

  Future<void> dispose() async => await _detector?.close();
}
