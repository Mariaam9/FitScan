import 'dart:io';
import 'package:uuid/uuid.dart';
import 'db/database_service.dart';
import '../models/analysis_result_model.dart';
import 'auth_service.dart';

class SessionService {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final _uuid = const Uuid();

  String? get _userId => _auth.currentUser?.uid;

  Future<List<SessionModel>> getAllSessions() async {
    if (_userId == null) return [];
    return await _db.getSessions(_userId!);
  }

  Future<List<SessionModel>> getRecentSessions({int limit = 5}) async {
    if (_userId == null) return [];
    return await _db.getRecentSessions(_userId!, limit: limit);
  }

  Future<String> saveSession(SessionModel session, {File? imageFile}) async {
    if (_userId == null) throw Exception('Non connecté');

    String? imagePath;
    if (imageFile != null) {
      imagePath = await _db.saveImage(imageFile, session.id);
    }

    final s = SessionModel(
      id: session.id,
      userId: _userId!,
      type: session.type,
      date: session.date,
      imagePath: imagePath,
      poseResult: session.poseResult,
      objectResult: session.objectResult,
      labelResult: session.labelResult,
      faceResult: session.faceResult,
    );

    return await _db.insertSession(s);
  }

  Future<void> deleteSession(String sessionId) async {
    if (_userId == null) return;
    await _db.deleteSession(sessionId, _userId!);
  }

  Future<void> deleteAllSessions() async {
    if (_userId == null) return;
    await _db.deleteAllSessions(_userId!);
  }
}
