import 'dart:convert';

enum AnalysisType {
  pose,
  object,
  labeling,
  face;

  String get label {
    switch (this) {
      case AnalysisType.pose:
        return 'Pose Detection';
      case AnalysisType.object:
        return 'Object Detection';
      case AnalysisType.labeling:
        return 'Image Labeling';
      case AnalysisType.face:
        return 'Face Detection';
    }
  }

  String get emoji {
    switch (this) {
      case AnalysisType.pose:
        return '🧘';
      case AnalysisType.object:
        return '🏋️';
      case AnalysisType.labeling:
        return '🏃';
      case AnalysisType.face:
        return '😓';
    }
  }

  String get description {
    switch (this) {
      case AnalysisType.pose:
        return 'Analyse de posture et articulations';
      case AnalysisType.object:
        return 'Détection de l\'équipement sportif';
      case AnalysisType.labeling:
        return 'Reconnaissance du type d\'exercice';
      case AnalysisType.face:
        return 'Estimation de l\'intensité perçue (RPE)';
    }
  }

  static AnalysisType fromString(String v) =>
      AnalysisType.values.firstWhere((e) => e.name == v,
          orElse: () => AnalysisType.pose);
}

class PoseResult {
  final int score;
  final List<String> errors;
  final List<String> corrections;
  final Map<String, double> jointAngles;

  const PoseResult({
    required this.score,
    required this.errors,
    required this.corrections,
    required this.jointAngles,
  });

  factory PoseResult.fromMap(Map<String, dynamic> m) => PoseResult(
        score: m['score'] ?? 0,
        errors: List<String>.from(m['errors'] ?? []),
        corrections: List<String>.from(m['corrections'] ?? []),
        jointAngles: Map<String, double>.from(m['jointAngles'] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        'score': score,
        'errors': errors,
        'corrections': corrections,
        'jointAngles': jointAngles,
      };

  String toJson() => jsonEncode(toMap());
  factory PoseResult.fromJson(String json) => PoseResult.fromMap(jsonDecode(json));
}

class DetectedObject {
  final String label;
  final double confidence;
  final Map<String, double>? boundingBox;

  const DetectedObject({
    required this.label,
    required this.confidence,
    this.boundingBox,
  });

  factory DetectedObject.fromMap(Map<String, dynamic> m) => DetectedObject(
        label: m['label'] ?? '',
        confidence: (m['confidence'] ?? 0.0).toDouble(),
        boundingBox: m['boundingBox'] != null
            ? Map<String, double>.from(m['boundingBox'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'confidence': confidence,
        if (boundingBox != null) 'boundingBox': boundingBox,
      };
}

class ObjectResult {
  final List<DetectedObject> objects;
  final List<String> trainingTips;

  const ObjectResult({required this.objects, required this.trainingTips});

  factory ObjectResult.fromMap(Map<String, dynamic> m) => ObjectResult(
        objects: (m['objects'] as List? ?? [])
            .map((o) => DetectedObject.fromMap(o as Map<String, dynamic>))
            .toList(),
        trainingTips: List<String>.from(m['trainingTips'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'objects': objects.map((o) => o.toMap()).toList(),
        'trainingTips': trainingTips,
      };

  String toJson() => jsonEncode(toMap());
  factory ObjectResult.fromJson(String json) => ObjectResult.fromMap(jsonDecode(json));
}

class LabelResult {
  final String topLabel;
  final double confidence;
  final List<Map<String, dynamic>> allLabels;
  final List<String> suggestedExercises;

  const LabelResult({
    required this.topLabel,
    required this.confidence,
    required this.allLabels,
    required this.suggestedExercises,
  });

  factory LabelResult.fromMap(Map<String, dynamic> m) => LabelResult(
        topLabel: m['topLabel'] ?? '',
        confidence: (m['confidence'] ?? 0.0).toDouble(),
        allLabels: List<Map<String, dynamic>>.from(m['allLabels'] ?? []),
        suggestedExercises: List<String>.from(m['suggestedExercises'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'topLabel': topLabel,
        'confidence': confidence,
        'allLabels': allLabels,
        'suggestedExercises': suggestedExercises,
      };

  String toJson() => jsonEncode(toMap());
  factory LabelResult.fromJson(String json) => LabelResult.fromMap(jsonDecode(json));
}

class FaceResult {
  final int rpeScore;
  final String effortLabel;
  final List<String> expressions;
  final String fatigueAdvice;
  final bool highFatigueAlert;
  final double smileProb;
  final double eyesOpenProb;

  const FaceResult({
    required this.rpeScore,
    required this.effortLabel,
    required this.expressions,
    required this.fatigueAdvice,
    required this.highFatigueAlert,
    required this.smileProb,
    required this.eyesOpenProb,
  });

  factory FaceResult.fromMap(Map<String, dynamic> m) => FaceResult(
        rpeScore: m['rpeScore'] ?? 5,
        effortLabel: m['effortLabel'] ?? 'Modéré',
        expressions: List<String>.from(m['expressions'] ?? []),
        fatigueAdvice: m['fatigueAdvice'] ?? '',
        highFatigueAlert: m['highFatigueAlert'] ?? false,
        smileProb: (m['smileProb'] ?? 0.5).toDouble(),
        eyesOpenProb: (m['eyesOpenProb'] ?? 0.5).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'rpeScore': rpeScore,
        'effortLabel': effortLabel,
        'expressions': expressions,
        'fatigueAdvice': fatigueAdvice,
        'highFatigueAlert': highFatigueAlert,
        'smileProb': smileProb,
        'eyesOpenProb': eyesOpenProb,
      };

  String toJson() => jsonEncode(toMap());
  factory FaceResult.fromJson(String json) => FaceResult.fromMap(jsonDecode(json));
}

class SessionModel {
  final String id;
  final String userId;
  final AnalysisType type;
  final DateTime date;
  final String? imagePath;   // ✅ Chemin local de l'image (SQLite)
  final PoseResult? poseResult;
  final ObjectResult? objectResult;
  final LabelResult? labelResult;
  final FaceResult? faceResult;

  const SessionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    this.imagePath,
    this.poseResult,
    this.objectResult,
    this.labelResult,
    this.faceResult,
  });

  /// Score synthétique affiché dans l'historique
  int get displayScore {
    switch (type) {
      case AnalysisType.pose:
        return poseResult?.score ?? 0;
      case AnalysisType.object:
        return (objectResult?.objects.length ?? 0) * 10;
      case AnalysisType.labeling:
        return ((labelResult?.confidence ?? 0) * 100).round();
      case AnalysisType.face:
        return ((faceResult?.rpeScore ?? 5) * 10);
    }
  }

  // Conversion pour SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'date': date.millisecondsSinceEpoch,
        'image_path': imagePath,
        'pose_result': poseResult?.toJson(),
        'object_result': objectResult?.toJson(),
        'label_result': labelResult?.toJson(),
        'face_result': faceResult?.toJson(),
      };

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      userId: map['user_id'],
      type: AnalysisType.fromString(map['type']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      imagePath: map['image_path'],
      poseResult: map['pose_result'] != null ? PoseResult.fromJson(map['pose_result']) : null,
      objectResult: map['object_result'] != null ? ObjectResult.fromJson(map['object_result']) : null,
      labelResult: map['label_result'] != null ? LabelResult.fromJson(map['label_result']) : null,
      faceResult: map['face_result'] != null ? FaceResult.fromJson(map['face_result']) : null,
    );
  }
}