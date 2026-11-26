import 'package:cloud_firestore/cloud_firestore.dart';

/// Peran pengguna (Authorization). Disimpan di Firestore `users/{uid}.role`
/// dan diperiksa juga oleh Firestore Security Rules.
enum UserRole {
  user('Pengguna'),
  admin('Admin');

  const UserRole(this.label);
  final String label;

  bool get canManage => this == UserRole.admin;

  static UserRole parse(String? value) => UserRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => UserRole.user,
      );
}

final class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = UserRole.user,
    this.fcmToken,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? fcmToken;
  final DateTime? createdAt;

  bool get isAdmin => role.canManage;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      displayName: d['displayName'] as String? ?? 'Pengguna',
      role: UserRole.parse(d['role'] as String?),
      fcmToken: d['fcmToken'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role.name,
        if (fcmToken != null) 'fcmToken': fcmToken,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };

  AppUser copyWith({String? displayName, UserRole? role, String? fcmToken}) =>
      AppUser(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
      );
}
