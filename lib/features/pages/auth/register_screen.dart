import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );

      if (mounted && user != null) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_mapError(e.toString())),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String err) {
    if (err.contains('email-already-in-use'))
      return 'Cet email est déjà utilisé';
    if (err.contains('weak-password'))
      return 'Mot de passe trop faible (6 caractères minimum)';
    if (err.contains('invalid-email')) return 'Email invalide';
    if (err.contains('network-request-failed'))
      return 'Erreur réseau - Vérifiez votre connexion';
    return 'Erreur d\'inscription — réessayez';
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
                    title: 'Créer un\ncompte',
                    subtitle: 'Rejoignez FitScan gratuitement',
                  ).animate().slideY(begin: -0.2, duration: 500.ms).fade(),
                  const SizedBox(height: 40),

                  // Nom complet
                  AuthTextField(
                    controller: _nameCtrl,
                    label: 'Nom complet',
                    hint: 'Mariem Kallel',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                  ).animate(delay: 100.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),

                  // Email
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'exemple@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email requis';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(v)) return 'Email invalide';
                      return null;
                    },
                  ).animate(delay: 200.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),

                  // Mot de passe
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Mot de passe requis';
                      if (v.length < 6) return 'Au moins 6 caractères';
                      return null;
                    },
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ).animate(delay: 300.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),

                  // Confirmer mot de passe
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirmPassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (v) => (v != _passCtrl.text)
                        ? 'Mots de passe différents'
                        : null,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ).animate(delay: 400.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 32),

                  // Bouton inscription
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Créer mon compte',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ).animate(delay: 500.ms).slideY(begin: 0.2).fade(),
                  const SizedBox(height: 16),

                  // Lien vers login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Déjà un compte ? ',
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Se connecter',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ).animate(delay: 600.ms).fade(),
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
