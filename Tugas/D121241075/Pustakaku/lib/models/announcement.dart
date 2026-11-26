import 'package:cloud_firestore/cloud_firestore.dart';

/// Pengumuman dibuat admin. Cloud Function `onAnnouncementCreated`
/// mengirim push notification ke topic `pengumuman` setiap dokumen baru.
final class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String authorName;
  final DateTime? createdAt;

  factory Announcement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Announcement(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Admin',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
