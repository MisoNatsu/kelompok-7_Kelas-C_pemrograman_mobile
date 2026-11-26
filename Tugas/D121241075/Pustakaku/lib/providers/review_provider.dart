import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';
import 'service_providers.dart';

final reviewsProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, bookId) {
  return ref.watch(firestoreServiceProvider).watchReviews(bookId);
});

/// Rata-rata rating dihitung dari stream ulasan (provider turunan).
final averageRatingProvider =
    Provider.autoDispose.family<double?, String>((ref, bookId) {
  final reviews = ref.watch(reviewsProvider(bookId)).value;
  if (reviews == null || reviews.isEmpty) return null;
  final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
  return total / reviews.length;
});
