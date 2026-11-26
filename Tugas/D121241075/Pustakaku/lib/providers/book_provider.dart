import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/book.dart';
import 'service_providers.dart';

// ---------- State pencarian (sealed class) ----------

sealed class SearchState {
  const SearchState();
}

/// Belum ada kata kunci: beranda menampilkan buku tren.
final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading(this.query);
  final String query;
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.query,
    required this.books,
    required this.totalFound,
    required this.page,
    this.isLoadingMore = false,
  });

  final String query;
  final List<Book> books;
  final int totalFound;
  final int page;
  final bool isLoadingMore;

  bool get hasMore => books.length < totalFound;

  SearchLoaded copyWith({
    List<Book>? books,
    int? page,
    bool? isLoadingMore,
  }) =>
      SearchLoaded(
        query: query,
        books: books ?? this.books,
        totalFound: totalFound,
        page: page ?? this.page,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

final class SearchError extends SearchState {
  const SearchError(this.query, this.message);
  final String query;
  final String message;
}

// ---------- Notifier ----------

class BookSearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;
  int _requestId = 0; // mencegah respons lama menimpa respons baru

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchIdle();
  }

  /// Dipanggil setiap ketikan; pencarian dijalankan 500 ms setelah berhenti mengetik.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => search(q));
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return clear();
    final id = ++_requestId;
    state = SearchLoading(q);

    final result = await ref.read(openLibraryApiProvider).search(q);
    if (id != _requestId) return; // sudah ada pencarian yang lebih baru

    state = switch (result) {
      Success(data: (:final books, :final totalFound)) => SearchLoaded(
          query: q,
          books: books,
          totalFound: totalFound,
          page: 1,
        ),
      Failure(:final message) => SearchError(q, message),
    };
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SearchLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    final id = _requestId;
    state = current.copyWith(isLoadingMore: true);

    final result = await ref
        .read(openLibraryApiProvider)
        .search(current.query, page: current.page + 1);
    if (id != _requestId) return;

    state = switch (result) {
      Success(data: (:final books, totalFound: _)) => current.copyWith(
          books: [...current.books, ...books],
          page: current.page + 1,
          isLoadingMore: false,
        ),
      Failure() => current.copyWith(isLoadingMore: false),
    };
  }

  void clear() {
    _debounce?.cancel();
    _requestId++;
    state = const SearchIdle();
  }
}

final bookSearchProvider =
    NotifierProvider<BookSearchNotifier, SearchState>(BookSearchNotifier.new);

/// Buku tren harian untuk beranda.
final trendingBooksProvider = FutureProvider<List<Book>>((ref) async {
  final result = await ref.watch(openLibraryApiProvider).trending();
  return result.getOrThrow();
});

/// Detail buku per workId. `autoDispose` -> cache dibuang saat halaman ditutup.
final bookDetailProvider =
    FutureProvider.autoDispose.family<BookDetail, String>((ref, workId) async {
  final result = await ref.watch(openLibraryApiProvider).detail(workId);
  return result.getOrThrow();
});
