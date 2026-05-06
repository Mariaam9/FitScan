import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscure = true;
  bool _isLoading = false;
  bool _isResetting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      
      if (mounted && user != null) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) _showError(_mapError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error, duration: const Duration(seconds: 3)),
    );
  }

  String _mapError(String err) {
    if (err.contains('user-not-found')) return 'Aucun compte avec cet email';
    if (err.contains('wrong-password')) return 'Mot de passe incorrect';
    if (err.contains('invalid-email')) return 'Email invalide';
    if (err.contains('too-many-requests')) return 'Trop de tentatives — réessayez plus tard';
    if (err.contains('network-request-failed')) return 'Erreur réseau - Vérifiez votre connexion';
    return 'Erreur de connexion — vérifiez vos identifiants';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const AuthHeader(
                    title: 'Bienvenue\nsur FitScan',
                    subtitle: 'Connectez-vous pour continuer',
                  ).animate().slideY(begin: -0.2, duration: 500.ms).fade(),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'exemple@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email requis';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Email invalide';
                      return null;
                    },
                  ).animate(delay: 100.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passCtrl,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Mot de passe requis';
                      if (v.length < 6) return 'Au moins 6 caractères';
                      return null;
                    },
                  ).animate(delay: 200.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,

                  ).animate(delay: 250.ms).fade(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ).animate(delay: 300.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pas de compte ? ', style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('S\'inscrire', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ).animate(delay: 400.ms).fade(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}