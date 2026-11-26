import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/result.dart';
import '../models/announcement.dart';
import '../models/app_user.dart';
import '../models/book.dart';
import '../models/review.dart';

/// Semua akses Cloud Firestore dikumpulkan di satu tempat.
///
/// Struktur koleksi:
/// ```
/// users/{uid}                       -> AppUser (role: user|admin, fcmToken)
/// users/{uid}/favorites/{workId}    -> Book.toMap()
/// reviews/{id}                      -> Review
/// announcements/{id}                -> Announcement
/// ```
final class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ---------- Users ----------

  Stream<AppUser?> watchUser(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  Stream<List<AppUser>> watchAllUsers() => _db
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(AppUser.fromDoc).toList());

  Future<void> saveFcmToken(String uid, String token) => _db
      .collection('users')
      .doc(uid)
      .set({'fcmToken': token}, SetOptions(merge: true));

  Future<void> saveInstallationId(String uid, String fid) => _db
      .collection('users')
      .doc(uid)
      .set({'fid': fid}, SetOptions(merge: true));

  /// Hanya admin (diverifikasi Firestore rules).
  Future<Result<void>> setRole(String uid, UserRole role) => guard(
        () => _db.collection('users').doc(uid).update({'role': role.name}),
        onError: _message,
      );

  // ---------- Favorites ----------

  CollectionReference<Map<String, dynamic>> _favs(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  Stream<List<Book>> watchFavorites(String uid) => _favs(uid)
      .orderBy('savedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Book.fromMap(d.data())).toList());

  Future<Result<void>> toggleFavorite(String uid, Book book) => guard(
        () async {
          final ref = _favs(uid).doc(book.workId);
          final snap = await ref.get();
          if (snap.exists) {
            await ref.delete();
          } else {
            await ref.set({
              ...book.toMap(),
              'savedAt': FieldValue.serverTimestamp(),
            });
          }
        },
        onError: _message,
      );

  // ---------- Reviews ----------

  Stream<List<Review>> watchReviews(String bookId) => _db
      .collection('reviews')
      .where('bookId', isEqualTo: bookId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Review.fromDoc).toList());

  Future<Result<void>> addReview(Review review) => guard(
        () => _db.collection('reviews').add(review.toMap()),
        onError: _message,
      );

  Future<Result<void>> deleteReview(String id) => guard(
        () => _db.collection('reviews').doc(id).delete(),
        onError: _message,
      );

  // ---------- Announcements ----------

  Stream<List<Announcement>> watchAnnouncements() => _db
      .collection('announcements')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Announcement.fromDoc).toList());

  Future<Result<void>> addAnnouncement({
    required String title,
    required String body,
    required AppUser author,
  }) =>
      guard(
        () => _db.collection('announcements').add({
          'title': title.trim(),
          'body': body.trim(),
          'authorName': author.displayName,
          'authorUid': author.uid,
          'createdAt': FieldValue.serverTimestamp(),
        }),
        onError: _message,
      );

  Future<Result<void>> deleteAnnouncement(String id) => guard(
        () => _db.collection('announcements').doc(id).delete(),
        onError: _message,
      );

  String _message(Object e) => switch (e) {
        FirebaseException(code: 'permission-denied') =>
          'Anda tidak memiliki izin untuk aksi ini.',
        FirebaseException(code: 'unavailable') =>
          'Tidak ada koneksi ke server.',
        FirebaseException(:final message) => message ?? 'Kesalahan Firestore.',
        _ => 'Terjadi kesalahan.',
      };
}
