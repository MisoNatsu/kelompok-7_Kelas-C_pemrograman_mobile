import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/book.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

/// Favorit pengguna yang sedang login (realtime dari Firestore).
final favoritesProvider = StreamProvider<List<Book>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchFavorites(user.uid);
});

/// Provider turunan: apakah sebuah buku ada di favorit?
final isFavoriteProvider = Provider.family<bool, String>((ref, workId) {
  final favs = ref.watch(favoritesProvider).value ?? const [];
  return favs.any((b) => b.workId == workId);
});

/// Aksi toggle favorit, dipisah agar widget tidak memegang service langsung.
final toggleFavoriteProvider =
    Provider<Future<Result<void>> Function(Book)>((ref) {
  return (book) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return const Result.failure('Silakan login dulu.');
    return ref.read(firestoreServiceProvider).toggleFavorite(user.uid, book);
  };
});
