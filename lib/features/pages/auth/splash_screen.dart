import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    
    final user = await _authService.getCurrentUser();
    context.go(user != null ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgPrimaryLight, Color(0xFFE8EAF6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fade(),
              const SizedBox(height: 28),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'FitScan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ).animate(delay: 300.ms).slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut).fade(),
              const SizedBox(height: 8),
              const Text(
                'Coach Fitness Intelligent',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ).animate(delay: 500.ms).fade(duration: 400.ms),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ServiceDot('🧘', AppColors.poseColor, 700),
                  _ServiceDot('🏋️', AppColors.objectColor, 850),
                  _ServiceDot('🏃', AppColors.labelColor, 1000),
                  _ServiceDot('😓', AppColors.faceColor, 1150),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ).animate(delay: 800.ms).fade(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceDot extends StatelessWidget {
  final String emoji;
  final Color color;
  final int delayMs;
  const _ServiceDot(this.emoji, this.color, this.delayMs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delayMs))
      .scale(begin: const Offset(0, 0), duration: 400.ms, curve: Curves.elasticOut)
      .fade();
  }
}