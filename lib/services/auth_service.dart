import 'package:firebase_auth/firebase_auth.dart';
import 'db/database_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return await _getOrCreateUser(cred.user!);
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);

    final user = UserModel(
      uid: cred.user!.uid,
      email: email.trim(),
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _db.insertUser(user);
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _getOrCreateUser(user);
  }

  Future<UserModel?> _getOrCreateUser(User fbUser) async {
    var user = await _db.getUser(fbUser.uid);
    
    if (user == null) {
      user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'Utilisateur',
        createdAt: DateTime.now(),
      );
      await _db.insertUser(user);
    }
    
    return user;
  }
}