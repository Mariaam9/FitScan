import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _preloadSounds();
      _isInitialized = true;
    } catch (e) {
      print('Erreur initialisation SoundService: $e');
    }
  }

  static Future<void> _preloadSounds() async {
    final sounds = ['success.mp3', 'error.mp3', 'tap.mp3', 'scan.mp3', 'notification.mp3'];
    for (final sound in sounds) {
      try {
        await _player.setSourceAsset('sounds/$sound');
      } catch (e) {
        print('Impossible de précharger $sound: $e');
      }
    }
  }

  static Future<bool> _isSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('sound_enabled') ?? true;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> _isVibrationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('vibration_enabled') ?? true;
    } catch (e) {
      return true;
    }
  }

  static Future<void> playSound(String soundName) async {
    final soundEnabled = await _isSoundEnabled();
    if (!soundEnabled) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$soundName'));
    } catch (e) {
      print('Erreur lecture son $soundName: $e');
    }
  }

  static Future<void> playSuccess() async {
    await playSound('success.mp3');
    await vibrate(duration: 100);
  }

  static Future<void> playError() async {
    await playSound('error.mp3');
    await vibrate(duration: 200);
  }

  static Future<void> playTap() async {
    await playSound('tap.mp3');
  }

  static Future<void> playScan() async {
    await playSound('scan.mp3');
  }

  static Future<void> playNotification() async {
    await playSound('notification.mp3');
  }

  static Future<void> vibrate({int duration = 50, VibrateType type = VibrateType.simple}) async {
    final vibrationEnabled = await _isVibrationEnabled();
    if (!vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        if (type == VibrateType.simple) {
          await Vibration.vibrate(duration: duration);
        } else {
          await Vibration.vibrate(pattern: [0, duration, 100, duration]);
        }
      }
    } catch (e) {
      print('Erreur vibration: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}

enum VibrateType { simple, pattern }