import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/mixins.dart';
import '../core/result.dart';
import '../models/app_user.dart';

/// Authentication dengan Firebase Auth (email & kata sandi).
/// Saat registrasi, dokumen `users/{uid}` dibuat dengan role default `user`.
final class AuthService with LoggerMixin {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<Result<User>> signIn(String email, String password) => guard(
        () async {
          final cred = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
          return cred.user!;
        },
        onError: _message,
      );

  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      guard(
        () async {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
          final user = cred.user!;
          await user.updateDisplayName(name.trim());
          // Buat profil + role default. Role hanya bisa diubah admin
          // (dilindungi Firestore rules).
          final profile = AppUser(
            uid: user.uid,
            email: user.email ?? email,
            displayName: name.trim(),
          );
          await _db.collection('users').doc(user.uid).set(profile.toMap());
          return user;
        },
        onError: _message,
      );

  Future<Result<void>> resetPassword(String email) => guard(
        () => _auth.sendPasswordResetEmail(email: email.trim()),
        onError: _message,
      );

  Future<void> signOut() => _auth.signOut();

  /// Menerjemahkan kode error Firebase ke Bahasa Indonesia.
  String _message(Object e) {
    log(e);
    if (e is! FirebaseAuthException) return 'Terjadi kesalahan. Coba lagi.';
    return switch (e.code) {
      'invalid-email' => 'Format email tidak valid.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Email atau kata sandi salah.',
      'email-already-in-use' => 'Email sudah terdaftar.',
      'weak-password' => 'Kata sandi terlalu lemah (minimal 6 karakter).',
      'too-many-requests' => 'Terlalu banyak percobaan. Coba beberapa saat lagi.',
      'network-request-failed' => 'Tidak ada koneksi internet.',
      'user-disabled' => 'Akun ini dinonaktifkan.',
      _ => e.message ?? 'Terjadi kesalahan (${e.code}).',
    };
  }
}
