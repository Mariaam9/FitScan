import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../../services/sound_service.dart';
import '../widgets/common/custom_app_bar.dart';
import '../../app/app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();
  
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  Locale _locale = const Locale('fr', 'FR');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await _settingsService.getThemeMode();
    final sound = await _settingsService.isSoundEnabled();
    final vibration = await _settingsService.isVibrationEnabled();
    final locale = await _settingsService.getLocale();
    
    setState(() {
      _isDarkMode = themeMode == ThemeMode.dark;
      _soundEnabled = sound;
      _vibrationEnabled = vibration;
      _locale = locale;
      _isLoading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    final newMode = value ? ThemeMode.dark : ThemeMode.light;
    await _settingsService.saveThemeMode(newMode);
    await SoundService.playTap();
    
    if (mounted) {
      final appState = context.findAncestorStateOfType<FitScanAppState>();
      appState?.updateTheme(newMode);
    }
  }

  Future<void> _changeLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    setState(() => _locale = newLocale);
    await _settingsService.saveLocale(newLocale);
    await SoundService.playTap();
    
    if (mounted) {
      final appState = context.findAncestorStateOfType<FitScanAppState>();
      appState?.updateLocale(newLocale);
      setState(() {});
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await _settingsService.saveSoundEnabled(value);
    if (value) await SoundService.playTap();
  }

  Future<void> _toggleVibration(bool value) async {
    setState(() => _vibrationEnabled = value);
    await _settingsService.saveVibrationEnabled(value);
  }

  Future<void> _logout() async {
    await SoundService.playTap();
    await _authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isRtl = AppLocalizations.of(context).isRtl;
    final scaffoldState = Scaffold.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: t.t('settings_title'),
        onMenuPressed: () => scaffoldState.openDrawer(),
        showProfileButton: false,
      ),
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: t.t('settings_theme'),
              children: [
                _SettingTile(
                  icon: Icons.palette_outlined,
                  label: t.t('settings_dark_mode'),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                    activeColor: AppColors.primary,
                  ),
                ),
                _SettingTile(
                  icon: Icons.language_rounded,
                  label: t.t('settings_language'),
                  trailing: DropdownButton<Locale>(
                    value: _locale,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('fr', 'FR'),
                        child: Text('🇫🇷 Français'),
                      ),
                      DropdownMenuItem(
                        value: Locale('en', 'US'),
                        child: Text('🇬🇧 English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('ar', 'TN'),
                        child: Text('🇹🇳 العربية'),
                      ),
                    ],
                    onChanged: _changeLocale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: t.t('settings_sound'),
              children: [
                _SwitchTile(
                  icon: Icons.volume_up_outlined,
                  label: t.t('settings_sound_enabled'),
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                ),
                _SwitchTile(
                  icon: Icons.vibration_rounded,
                  label: t.t('settings_vibration'),
                  value: _vibrationEnabled,
                  onChanged: _toggleVibration,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'COMPTE',
              children: [
                _SettingTile(
                  icon: Icons.logout_rounded,
                  label: 'Déconnexion',
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  onTap: _logout,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  
  const _SettingTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}