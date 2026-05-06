import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final String? emoji;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onClose;
  final PreferredSizeWidget? bottom;
  final bool showHelpButton;
  final bool showProfileButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.emoji,
    this.actions,
    this.onMenuPressed,
    this.onClose,
    this.bottom,
    this.showHelpButton = true,
    this.showProfileButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null ? kToolbarHeight + bottom!.preferredSize.height : kToolbarHeight
  );

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  String _getUserInitial() {
    if (_user == null) return '?';
    if (_user!.displayName.isNotEmpty) return _user!.displayName[0].toUpperCase();
    if (_user!.email.isNotEmpty) return _user!.email[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget titleWidget = Text(
      widget.emoji != null ? '${widget.emoji} ${widget.title}' : widget.title,
      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
    );

    List<Widget> defaultActions = [];

    if (widget.showHelpButton) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => context.go('/about'),
          tooltip: 'À propos',
        ),
      );
    }

    if (widget.showProfileButton && _user != null) {
      defaultActions.add(
        GestureDetector(
          onTap: () => context.go('/settings'),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(_getUserInitial(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ),
      );
    }

    if (widget.onClose != null) {
      defaultActions.add(IconButton(icon: const Icon(Icons.close_rounded), onPressed: widget.onClose, tooltip: 'Fermer'));
    }

    return AppBar(
      title: titleWidget,
      centerTitle: false,
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight,
      elevation: 0,
      leading: widget.showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop(), tooltip: 'Retour')
          : (widget.onMenuPressed != null
              ? IconButton(icon: const Icon(Icons.menu_rounded), onPressed: widget.onMenuPressed, tooltip: 'Menu')
              : null),
      actions: widget.actions ?? defaultActions,
      bottom: widget.bottom,
    );
  }
}