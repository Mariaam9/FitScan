import 'dart:io';
import '../models/analysis_result_model.dart';
import 'ml/pose_detection_service.dart';
import 'ml/object_detection_service.dart';
import 'ml/image_labeling_service.dart';
import 'ml/face_detection_service.dart';

class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  late PoseDetectionService _poseService;
  late ObjectDetectionService _objectService;
  late ImageLabelingService _labelingService;
  late FaceDetectionService _faceService;
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _poseService = PoseDetectionService();
    _objectService = ObjectDetectionService();
    _labelingService = ImageLabelingService();
    _faceService = FaceDetectionService();
    
    _isInitialized = true;
    print('✅ AnalysisService initialisé');
  }

  Future<PoseResult?> analyzePose(String imagePath) async {
    if (!_isInitialized) await init();
    try {
      print('🔍 Analyse Pose: $imagePath');
      final result = await _poseService.analyze(imagePath);
      print('✅ Résultat Pose: ${result?.score}');
      return result;
    } catch (e) {
      print('❌ Erreur analyse pose: $e');
      return null;
    }
  }

  Future<ObjectResult?> analyzeObject(String imagePath) async {
    if (!_isInitialized) await init();
    try {
      print('🔍 Analyse Object: $imagePath');
      final result = await _objectService.analyze(imagePath);
      print('✅ Résultat Object: ${result?.objects.length} objets');
      return result;
    } catch (e) {
      print('❌ Erreur analyse objet: $e');
      return null;
    }
  }

  Future<LabelResult?> analyzeLabel(String imagePath) async {
    if (!_isInitialized) await init();
    try {
      print('🔍 Analyse Label: $imagePath');
      final result = await _labelingService.analyze(imagePath);
      print('✅ Résultat Label: ${result?.topLabel}');
      return result;
    } catch (e) {
      print('❌ Erreur analyse label: $e');
      return null;
    }
  }

  Future<FaceResult?> analyzeFace(String imagePath) async {
    if (!_isInitialized) await init();
    try {
      print('🔍 Analyse Face: $imagePath');
      final result = await _faceService.analyze(imagePath);
      print('✅ Résultat Face: RPE ${result?.rpeScore}');
      return result;
    } catch (e) {
      print('❌ Erreur analyse visage: $e');
      return null;
    }
  }

  void dispose() {
    _poseService.dispose();
    _objectService.dispose();
    _labelingService.dispose();
    _faceService.dispose();
    _isInitialized = false;
  }
}