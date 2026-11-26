import 'package:cloud_firestore/cloud_firestore.dart';

final class Review {
  const Review({
    required this.id,
    required this.bookId,
    required this.uid,
    required this.authorName,
    required this.rating,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String bookId;
  final String uid;
  final String authorName;
  final int rating; // 1..5
  final String text;
  final DateTime? createdAt;

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Review(
      id: doc.id,
      bookId: d['bookId'] as String,
      uid: d['uid'] as String,
      authorName: d['authorName'] as String? ?? 'Anonim',
      rating: (d['rating'] as num?)?.toInt() ?? 0,
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'bookId': bookId,
        'uid': uid,
        'authorName': authorName,
        'rating': rating,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
