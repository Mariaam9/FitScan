import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Accent principal ──────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);       
  static const Color primaryLight = Color(0xFF9C95FF);
  static const Color primaryDark = Color(0xFF4A43CC);

  // ── Accents secondaires ───────────────────────────────────────
  static const Color secondary = Color(0xFF00BFA5);     
  static const Color accent = Color(0xFFFF5252);        

  // ── ML Kit — couleurs par service ────────────────────────────
  static const Color poseColor = Color(0xFF00E5FF);     
  static const Color objectColor = Color(0xFFFFD740);   
  static const Color labelColor = Color(0xFF69F0AE);    
  static const Color faceColor = Color(0xFFFF4081);     

  // ── Posture feedback ─────────────────────────────────────────
  static const Color poseGood = Color(0xFF4CAF50);
  static const Color poseBad = Color(0xFFF44336);
  static const Color poseLandmark = Color(0xFF00E5FF);
  static const Color poseConnection = Color(0xFF0097A7);

  // ── RPE / Effort ─────────────────────────────────────────────
  static const Color effortLow = Color(0xFF4CAF50);    
  static const Color effortMed = Color(0xFFFF9800);    
  static const Color effortHigh = Color(0xFFF44336);    
  static const Color effortMax = Color(0xFF9C27B0);   

  // ── Backgrounds Dark ─────────────────────────────────────────
  static const Color bgPrimaryDark = Color(0xFF121212);
  static const Color bgSecondaryDark = Color(0xFF1E1E1E);
  static const Color bgCardDark = Color(0xFF252525);
  static const Color bgElevatedDark = Color(0xFF2D2D2D);

  // ── Backgrounds Light ─────────────────────────────────────────
  static const Color bgPrimaryLight = Color(0xFFF5F5F5);
  static const Color bgSecondaryLight = Color(0xFFFFFFFF);
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgElevatedLight = Color(0xFFF0F0F0);

  // ── Textes Dark ───────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F0F0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color textMutedDark = Color(0xFF616161);

  // ── Textes Light ──────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textMutedLight = Color(0xFFBDBDBD);

  // ── États ────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ── Utilitaire ───────────────────────────────────────────────
  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFF1E1E1E);

  // Dégradé principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dégradé par service ML
  static const LinearGradient poseGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient objectGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient labelGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient faceGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE0979)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
