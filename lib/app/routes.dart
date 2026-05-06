import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/pages/auth/splash_screen.dart';
import '../features/pages/auth/login_screen.dart';
import '../features/pages/auth/register_screen.dart';
import '../features/pages/home_screen.dart';
import '../features/pages/pose_screen.dart';
import '../features/pages/object_screen.dart';
import '../features/pages/labeling_screen.dart';
import '../features/pages/face_screen.dart';
import '../features/pages/result_screen.dart';
import '../features/pages/history_screen.dart';
import '../features/pages/settings_screen.dart';
import '../features/pages/about_screen.dart';
import '../features/widgets/common/custom_sidebar.dart';

final routerConfig = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => CustomSidebar(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, __) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (_, __) => const AboutScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/pose',
      builder: (_, __) => const PoseScreen(),
    ),
    GoRoute(
      path: '/object',
      builder: (_, __) => const ObjectScreen(),
    ),
    GoRoute(
      path: '/labeling',
      builder: (_, __) => const LabelingScreen(),
    ),
    GoRoute(
      path: '/face',
      builder: (_, __) => const FaceScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResultScreen(data: extra ?? {});
      },
    ),
  ],
);