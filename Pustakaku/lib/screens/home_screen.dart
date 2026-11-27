import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../models/book.dart';
import '../providers/providers.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton.dart';
import 'book_detail_screen.dart';

/// Kategori di beranda. Nilai kedua adalah kueri pencarian Open Library,
/// `null` berarti kembali ke buku tren.
const _genres = <(String, String?)>[
  ('Semua', null),
  ('Gratis dibaca', 'ebook_access:public'),
  ('Fiksi', 'subject:fiction'),
  ('Bisnis', 'subject:business'),
  ('Psikologi', 'subject:psychology'),
  ('Sejarah', 'subject:history'),
  ('Sains', 'subject:science'),
  ('Fantasi', 'subject:fantasy'),
  ('Romansa', 'subject:romance'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  String? _genre; // label kategori aktif, null bila mencari teks bebas

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Infinite scroll: muat halaman berikutnya saat mendekati bawah.
      if (_scroll.hasClients && _scroll.position.extentAfter < 400) {
        ref.read(bookSearchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(Book book, {String heroTag = 'cover'}) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookDetailScreen(book: book, heroTag: '$heroTag-${book.workId}'),
        ),
      );

  void _pickGenre(String label, String? query) {
    final search = ref.read(bookSearchProvider.notifier);
    _controller.clear();
    FocusScope.of(context).unfocus();
    if (query == null) {
      setState(() => _genre = null);
      search.clear();
    } else {
      setState(() => _genre = label);
      search.search(query);
    }
  }

  void _clear() {
    _controller.clear();
    setState(() => _genre = null);
    ref.read(bookSearchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final search = ref.watch(bookSearchProvider);
    final firstName = ref.watch(appUserProvider).value?.displayName.split(' ').first;
    final activeGenre = search is SearchIdle ? 'Semua' : _genre;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName == null ? 'Halo, Pembaca' : 'Halo, $firstName',
                    style: context.text.bodyMedium?.copyWith(color: p.muted),
                  ),
                  const SizedBox(height: 2),
                  Text('Mau baca apa hari ini?', style: context.text.headlineMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau ISBN',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: search is SearchIdle
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _clear,
                            ),
                    ),
                    onChanged: (q) {
                      if (_genre != null) setState(() => _genre = null);
                      ref.read(bookSearchProvider.notifier).onQueryChanged(q);
                    },
                    onSubmitted: ref.read(bookSearchProvider.notifier).search,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                itemCount: _genres.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (label, query) = _genres[i];
                  return _GenreChip(
                    label: label,
                    selected: label == activeGenre,
                    onTap: () => _pickGenre(label, query),
                  );
                },
              ),
            ),
            Expanded(
              // Pattern matching pada sealed class: semua kasus wajib ditangani.
              child: switch (search) {
                SearchIdle() => _TrendingHome(onOpen: _open),
                SearchLoading() => const HomeSkeleton(),
                SearchError(:final query, :final message) => EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Pencarian gagal',
                    message: message,
                    action: FilledButton.tonal(
                      onPressed: () => ref.read(bookSearchProvider.notifier).search(query),
                      child: const Text('Coba lagi'),
                    ),
                  ),
                SearchLoaded(books: []) => const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak ada hasil',
                    message: 'Coba kata kunci atau kategori lain.',
                  ),
                SearchLoaded(:final books, :final totalFound, :final isLoadingMore, :final query) =>
                  ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: books.length + 2,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _genre != null
                                ? 'Kategori $_genre · $totalFound buku'
                                : '$totalFound hasil untuk "$query"',
                            style: context.text.labelLarge?.copyWith(color: p.muted),
                          ),
                        );
                      }
                      if (i == books.length + 1) {
                        return isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox(height: 24);
                      }
                      final book = books[i - 1];
                      return BookCard(book: book, onTap: () => _open(book));
                    },
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? p.primary : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: selected ? p.primary : p.lineStrong)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? p.onPrimary : p.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Beranda sebelum mencari: carousel buku tren lalu daftar sisanya.
class _TrendingHome extends ConsumerWidget {
  const _TrendingHome({required this.onOpen});
  final void Function(Book book, {String heroTag}) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingBooksProvider);
    return trending.when(
      loading: () => const HomeSkeleton(),
      error: (e, _) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat buku tren',
        message: '$e',
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(trendingBooksProvider),
          child: const Text('Coba lagi'),
        ),
      ),
      data: (books) {
        final featured = books.take(8).toList();
        final rest = books.skip(8).toList();
        return RefreshIndicator(
          onRefresh: () => ref.refresh(trendingBooksProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: SectionHeader('Sedang tren hari ini'),
              ),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => CoverTile(
                    book: featured[i],
                    heroPrefix: 'tile',
                    onTap: () => onOpen(featured[i], heroTag: 'tile'),
                  ),
                ),
              ),
              if (rest.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: SectionHeader('Pilihan untukmu'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final book in rest) BookCard(book: book, onTap: () => onOpen(book)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
