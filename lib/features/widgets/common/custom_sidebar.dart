import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/sound_service.dart';
import '../../../models/user_model.dart';

class CustomSidebar extends StatefulWidget {
  final Widget child;
  const CustomSidebar({super.key, required this.child});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  String _getUserInitial() {
    if (_user == null) return '?';
    if (_user!.displayName.isNotEmpty) return _user!.displayName[0].toUpperCase();
    if (_user!.email.isNotEmpty) return _user!.email[0].toUpperCase();
    return '?';
  }

  Future<void> _logout() async {
    await SoundService.playTap();
    await _authService.signOut();
    if (mounted) {
      Navigator.pop(context);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: _isLoading
                    ? const Column(children: [
                        CircleAvatar(radius: 40, backgroundColor: Colors.white, child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                        SizedBox(height: 12),
                        Text('Chargement...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ])
                    : Column(children: [
                        CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Text(_getUserInitial(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary))),
                        const SizedBox(height: 12),
                        Text(_user?.displayName ?? 'Utilisateur', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_user?.email ?? 'email@example.com', style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ]),
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(Icons.home_outlined, 'Accueil', () { Navigator.pop(context); context.go('/home'); }),
              _buildDrawerItem(Icons.history_outlined, 'Historique', () { Navigator.pop(context); context.go('/history'); }),
              _buildDrawerItem(Icons.fitness_center_outlined, 'Pose Detection', () { Navigator.pop(context); context.push('/pose'); }),
              _buildDrawerItem(Icons.fitness_center_outlined, 'Object Detection', () { Navigator.pop(context); context.push('/object'); }),
              _buildDrawerItem(Icons.run_circle_outlined, 'Image Labeling', () { Navigator.pop(context); context.push('/labeling'); }),
              _buildDrawerItem(Icons.face_rounded, 'Face Detection', () { Navigator.pop(context); context.push('/face'); }),
              _buildDrawerItem(Icons.settings_outlined, 'Paramètres', () { Navigator.pop(context); context.go('/settings'); }),
              _buildDrawerItem(Icons.info_outline_rounded, 'À propos', () { Navigator.pop(context); context.go('/about'); }),
              const Divider(),
              _buildDrawerItem(Icons.logout_rounded, 'Déconnexion', _logout, iconColor: AppColors.error),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
      onTap: onTap,
    );
  }
}