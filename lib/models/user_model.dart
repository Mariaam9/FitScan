class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final int totalSessions;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.totalSessions = 0,
  });


  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'created_at': createdAt.millisecondsSinceEpoch,
        'total_sessions': totalSessions,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['display_name'],
      photoUrl: map['photo_url'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      totalSessions: map['total_sessions'] ?? 0,
    );
  }

  UserModel copyWith({String? displayName, String? photoUrl, int? totalSessions}) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}