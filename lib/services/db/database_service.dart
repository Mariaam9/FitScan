import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../models/analysis_result_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fitscan.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table users
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT NOT NULL,
        photo_url TEXT,
        created_at INTEGER NOT NULL,
        total_sessions INTEGER DEFAULT 0
      )
    ''');
    
    // Table sessions
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        image_path TEXT,
        pose_result TEXT,
        object_result TEXT,
        label_result TEXT,
        face_result TEXT,
        FOREIGN KEY (user_id) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');
    
    // Index pour les performances
    await db.execute('CREATE INDEX idx_sessions_user_id ON sessions(user_id)');
    await db.execute('CREATE INDEX idx_sessions_date ON sessions(date DESC)');
  }

  // ==================== USERS ====================
  
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'uid': user.uid,
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'total_sessions': user.totalSessions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    
    if (maps.isEmpty) return null;
    
    return UserModel(
      uid: maps[0]['uid'],
      email: maps[0]['email'],
      displayName: maps[0]['display_name'],
      photoUrl: maps[0]['photo_url'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(maps[0]['created_at']),
      totalSessions: maps[0]['total_sessions'],
    );
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'total_sessions': user.totalSessions,
      },
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  // ==================== SESSIONS ====================
  
  Future<String> insertSession(SessionModel session) async {
    final db = await database;
    
    await db.insert(
      'sessions',
      {
        'id': session.id,
        'user_id': session.userId,
        'type': session.type.name,
        'date': session.date.millisecondsSinceEpoch,
        'image_path': session.imagePath,
        'pose_result': session.poseResult != null ? jsonEncode(_poseResultToMap(session.poseResult!)) : null,
        'object_result': session.objectResult != null ? jsonEncode(_objectResultToMap(session.objectResult!)) : null,
        'label_result': session.labelResult != null ? jsonEncode(_labelResultToMap(session.labelResult!)) : null,
        'face_result': session.faceResult != null ? jsonEncode(_faceResultToMap(session.faceResult!)) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Mettre à jour le compteur de sessions
    await _incrementSessionCount(session.userId);
    
    return session.id;
  }

  Future<List<SessionModel>> getSessions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => SessionModel(
      id: map['id'],
      userId: map['user_id'],
      type: AnalysisType.fromString(map['type']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      imagePath: map['image_path'],
      poseResult: map['pose_result'] != null ? _poseResultFromMap(jsonDecode(map['pose_result'])) : null,
      objectResult: map['object_result'] != null ? _objectResultFromMap(jsonDecode(map['object_result'])) : null,
      labelResult: map['label_result'] != null ? _labelResultFromMap(jsonDecode(map['label_result'])) : null,
      faceResult: map['face_result'] != null ? _faceResultFromMap(jsonDecode(map['face_result'])) : null,
    )).toList();
  }

  Future<List<SessionModel>> getRecentSessions(String userId, {int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
    
    return maps.map((map) => SessionModel(
      id: map['id'],
      userId: map['user_id'],
      type: AnalysisType.fromString(map['type']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      imagePath: map['image_path'],
      poseResult: map['pose_result'] != null ? _poseResultFromMap(jsonDecode(map['pose_result'])) : null,
      objectResult: map['object_result'] != null ? _objectResultFromMap(jsonDecode(map['object_result'])) : null,
      labelResult: map['label_result'] != null ? _labelResultFromMap(jsonDecode(map['label_result'])) : null,
      faceResult: map['face_result'] != null ? _faceResultFromMap(jsonDecode(map['face_result'])) : null,
    )).toList();
  }

  Future<void> deleteSession(String sessionId, String userId) async {
    final db = await database;
    
    // Récupérer l'image avant suppression
    final List<Map<String, dynamic>> result = await db.query(
      'sessions',
      columns: ['image_path'],
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    
    if (result.isNotEmpty && result[0]['image_path'] != null) {
      await _deleteImageFile(result[0]['image_path']);
    }
    
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
    await _decrementSessionCount(userId);
  }

  Future<void> deleteAllSessions(String userId) async {
    final db = await database;
    
    // Récupérer toutes les images
    final List<Map<String, dynamic>> result = await db.query(
      'sessions',
      columns: ['image_path'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    for (var row in result) {
      if (row['image_path'] != null) {
        await _deleteImageFile(row['image_path']);
      }
    }
    
    await db.delete('sessions', where: 'user_id = ?', whereArgs: [userId]);
    await db.update('users', {'total_sessions': 0}, where: 'uid = ?', whereArgs: [userId]);
  }

  // ==================== IMAGES ====================
  
  Future<String> saveImage(File imageFile, String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/fitscan_images');
    
    if (!await imageDir.exists()) {
      await imageDir.create();
    }
    
    final fileName = '${sessionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final localPath = '${imageDir.path}/$fileName';
    
    await imageFile.copy(localPath);
    return localPath;
  }

  Future<File?> getImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur suppression image: $e');
    }
  }

  // ==================== COMPTEURS ====================
  
  Future<void> _incrementSessionCount(String userId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET total_sessions = total_sessions + 1 WHERE uid = ?',
      [userId],
    );
  }

  Future<void> _decrementSessionCount(String userId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET total_sessions = total_sessions - 1 WHERE uid = ? AND total_sessions > 0',
      [userId],
    );
  }

  // ==================== CONVERSIONS ====================
  
  Map<String, dynamic> _poseResultToMap(PoseResult result) => result.toMap();
  Map<String, dynamic> _objectResultToMap(ObjectResult result) => result.toMap();
  Map<String, dynamic> _labelResultToMap(LabelResult result) => result.toMap();
  Map<String, dynamic> _faceResultToMap(FaceResult result) => result.toMap();
  
  PoseResult _poseResultFromMap(Map<String, dynamic> map) => PoseResult.fromMap(map);
  ObjectResult _objectResultFromMap(Map<String, dynamic> map) => ObjectResult.fromMap(map);
  LabelResult _labelResultFromMap(Map<String, dynamic> map) => LabelResult.fromMap(map);
  FaceResult _faceResultFromMap(Map<String, dynamic> map) => FaceResult.fromMap(map);
}