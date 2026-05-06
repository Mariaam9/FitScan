import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../services/analysis_service.dart';
import '../../services/sound_service.dart';
import '../../models/analysis_result_model.dart';
import '../widgets/common/custom_app_bar.dart';

class ObjectScreen extends StatefulWidget {
  const ObjectScreen({super.key});

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  String? _imagePath;
  final _picker = ImagePicker();
  final AnalysisService _analysisService = AnalysisService();
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();
  final _uuid = const Uuid();
  
  ObjectResult? _result;
  bool _isAnalyzing = false;
  String? _error;

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isDenied) {
      _showError('Permission caméra refusée');
      return false;
    }
    if (status.isPermanentlyDenied) {
      _showError('Autorisez la caméra dans les paramètres');
      await openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera && !(await _checkCameraPermission())) return;
    
    await SoundService.playTap();
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    
    setState(() {
      _imagePath = file.path;
      _isAnalyzing = true;
      _error = null;
      _result = null;
    });
    
    await SoundService.playScan();
    
    try {
      final result = await _analysisService.analyzeObject(file.path);
      if (mounted) {
        setState(() {
          _result = result;
          _isAnalyzing = false;
          if (result == null) _error = 'Erreur lors de l\'analyse';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur: ${e.toString()}';
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final user = await _authService.getCurrentUser();
    if (user == null) { _showError('Vous devez être connecté'); return; }
    if (_result == null) return;

    final session = SessionModel(
      id: _uuid.v4(),
      userId: user.uid,
      type: AnalysisType.object,
      date: DateTime.now(),
      objectResult: _result,
    );
    
    File? imageFile = _imagePath != null ? File(_imagePath!) : null;
    final id = await _sessionService.saveSession(session, imageFile: imageFile);
    
    if (mounted && id.isNotEmpty) {
      await SoundService.playSuccess();
      await SoundService.vibrate(duration: 100);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Session sauvegardée !')));
      context.push('/result', extra: {'type': 'object', 'result': _result, 'sessionId': id});
    }
  }

  void _showError(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Object Detection',
        showBackButton: true,
        emoji: '🏋️',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showSourceDialog(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.objectColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _imagePath != null ? AppColors.objectColor : AppColors.objectColor.withOpacity(0.3),
                      width: _imagePath != null ? 2 : 1,
                    ),
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.objectColor.withOpacity(0.6)),
                            const SizedBox(height: 12),
                            Text('Appuyez pour choisir une image', style: TextStyle(color: AppColors.objectColor.withOpacity(0.7))),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                        ),
                ),
              ).animate().scale(begin: const Offset(0.95, 0.95)).fade(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Caméra'),
                      onPressed: () => _pick(ImageSource.camera),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.objectColor, side: BorderSide(color: AppColors.objectColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galerie'),
                      onPressed: () => _pick(ImageSource.gallery),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.objectColor, side: BorderSide(color: AppColors.objectColor)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isAnalyzing)
                const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Analyse en cours...')]))
              else if (_error != null)
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('Erreur : $_error', style: const TextStyle(color: AppColors.error)))
              else if (_result != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Résultats', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    _ObjectResultCard(result: _result!),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(icon: const Icon(Icons.save_rounded), label: const Text('Sauvegarder dans l\'historique'), onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.objectColor)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Prendre une photo'), onTap: () { Navigator.pop(context); _pick(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choisir depuis la galerie'), onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); }),
          ],
        ),
      ),
    );
  }
}

class _ObjectResultCard extends StatelessWidget {
  final ObjectResult result;
  const _ObjectResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.objectColor.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.objectColor.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objets détectés (${result.objects.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...result.objects.map((obj) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(obj.label),
                  Text('${(obj.confidence * 100).toStringAsFixed(0)}%', style: TextStyle(color: AppColors.objectColor)),
                ]),
              )),
          if (result.trainingTips.isNotEmpty) ...[
            const Divider(),
            const Text('Conseils:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...result.trainingTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [Icon(Icons.tips_and_updates, size: 14, color: AppColors.objectColor), const SizedBox(width: 4), Expanded(child: Text(tip, style: const TextStyle(fontSize: 12)))]),
                )),
          ],
        ],
      ),
    );
  }
}