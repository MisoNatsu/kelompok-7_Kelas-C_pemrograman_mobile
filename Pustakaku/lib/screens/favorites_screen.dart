import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../providers/providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import 'book_detail_screen.dart';

/// Favorit ditampilkan sebagai rak: grid sampul tiga kolom.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final count = favorites.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rak bukuku', style: context.text.headlineSmall),
            Text(
              count == 0 ? 'Belum ada buku tersimpan' : '$count buku tersimpan',
              style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
            ),
          ],
        ),
      ),
      body: AsyncValueWidget(
        value: favorites,
        onRetry: () => ref.invalidate(favoritesProvider),
        data: (books) => books.isEmpty
            ? const EmptyState(
                icon: Icons.bookmark_add_outlined,
                title: 'Rakmu masih kosong',
                message: 'Tekan ikon pembatas buku di halaman buku untuk menyimpannya di sini. '
                    'Raknya tersinkron di semua perangkatmu.',
              )
            : LayoutBuilder(
                builder: (context, c) {
                  const columns = 3;
                  const gap = 16.0;
                  final tileWidth = (c.maxWidth - 40 - gap * (columns - 1)) / columns;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: books.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: 20,
                      // tinggi = sampul 1.5x lebar + dua baris judul + penulis
                      childAspectRatio: tileWidth / (tileWidth * 1.5 + 68),
                    ),
                    itemBuilder: (_, i) => CoverTile(
                      book: books[i],
                      width: tileWidth,
                      heroPrefix: 'fav',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(
                            book: books[i],
                            heroTag: 'fav-${books[i].workId}',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
