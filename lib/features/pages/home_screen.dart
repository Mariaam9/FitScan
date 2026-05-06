import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../models/user_model.dart';
import '../../models/analysis_result_model.dart';
import '../widgets/home/ml_service_card.dart';
import '../widgets/home/recent_session_tile.dart';
import '../widgets/common/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  List<SessionModel> _recentSessions = [];
  bool _isLoading = true;
  bool _hasPermissions = false;

  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();

  static const _services = [
    {'route': '/pose', 'emoji': '🧘', 'label': 'Pose Detection', 'desc': 'Analyse posture & articulations', 'gradient': AppColors.poseGradient},
    {'route': '/object', 'emoji': '🏋️', 'label': 'Object Detection', 'desc': 'Détecte l\'équipement sportif', 'gradient': AppColors.objectGradient},
    {'route': '/labeling', 'emoji': '🏃', 'label': 'Image Labeling', 'desc': 'Reconnaît le type d\'exercice', 'gradient': AppColors.labelGradient},
    {'route': '/face', 'emoji': '😓', 'label': 'Face Detection', 'desc': 'Estime ton niveau d\'effort RPE', 'gradient': AppColors.faceGradient},
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoad();
  }

  Future<void> _checkPermissionsAndLoad() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;
    
    final allGranted = cameraStatus.isGranted && 
        (photosStatus.isGranted || storageStatus.isGranted);
    
    setState(() {
      _hasPermissions = allGranted;
    });
    
    if (!allGranted) {
      final statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();
      
      final newAllGranted = statuses[Permission.camera]!.isGranted &&
          (statuses[Permission.photos]!.isGranted || statuses[Permission.storage]!.isGranted);
      
      setState(() {
        _hasPermissions = newAllGranted;
      });
    }
    
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.getCurrentUser();
    final sessions = await _sessionService.getRecentSessions();
    
    setState(() {
      _user = user;
      _recentSessions = sessions;
      _isLoading = false;
    });
  }

  void _onServiceTap(String route) {
    if (!_hasPermissions) {
      _showPermissionDialog();
      return;
    }
    context.push(route);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions requises'),
        content: const Text(
          'L\'application a besoin d\'accéder à la caméra et au stockage pour analyser vos photos et vidéos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              _checkPermissionsAndLoad();
            },
            child: const Text('Ouvrir les paramètres'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'FitScan',
        onMenuPressed: () => scaffoldState.openDrawer(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salut, ${_user?.displayName.split(' ').first ?? 'Coach'} 👋',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ).animate().slideX(begin: -0.2).fade(),
                                const SizedBox(height: 4),
                                Text(
                                  'Prêt à analyser ta séance ?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ).animate(delay: 100.ms).fade(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.white, size: 36),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total séances', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${_user?.totalSessions ?? 0} analyses', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, minimumSize: const Size(0, 38)),
                              onPressed: () => context.go('/history'),
                              child: const Text('Voir tout'),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).slideY(begin: 0.3).fade(),
                    ),
                  ),
                  if (!_hasPermissions)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Autorisations requises pour la caméra',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ),
                              TextButton(
                                onPressed: () => openAppSettings(),
                                child: const Text('Paramètres'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                      child: Text('4 Services ML Kit', style: Theme.of(context).textTheme.titleLarge).animate(delay: 300.ms).fade(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: _services.map((s) => MLServiceCard(
                        emoji: s['emoji'] as String,
                        label: s['label'] as String,
                        description: s['desc'] as String,
                        gradient: s['gradient'] as LinearGradient,
                        onTap: () => _onServiceTap(s['route'] as String),
                      )).toList(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                      child: Text('Séances récentes', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  if (_recentSessions.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Aucune séance pour l\'instant')),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      sliver: SliverList.separated(
                        itemCount: _recentSessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => RecentSessionTile(session: _recentSessions[i]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}