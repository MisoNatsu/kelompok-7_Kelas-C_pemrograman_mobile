import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../models/book.dart';
import '../providers/providers.dart';
import 'book_cover.dart';

/// Kartu buku untuk daftar: sampul, judul serif, penulis, tahun, tombol favorit.
class BookCard extends ConsumerWidget {
  const BookCard({super.key, required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isFav = ref.watch(isFavoriteProvider(book.workId));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                BookCover.ofBook(book, width: 60, height: 90, heroTag: 'cover-${book.workId}'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: context.text.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authorLabel,
                        style: context.text.bodyMedium?.copyWith(color: p.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (book.firstPublishYear case final year?) _Badge('$year'),
                          if (book.pages case final pages?) _Badge('$pages hlm'),
                          if (book.rating case final rating?)
                            _Badge('★ ${rating.toStringAsFixed(1)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: p.primary,
                  ),
                  onPressed: () async {
                    final result = await ref.read(toggleFavoriteProvider)(book);
                    if (!context.mounted) return;
                    result.when(
                      success: (_) {},
                      failure: (m) => context.showSnack(m, error: true),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.onAccentSoft),
      ),
    );
  }
}

/// Sampul besar dengan judul di bawahnya, untuk carousel dan rak favorit.
class CoverTile extends StatelessWidget {
  const CoverTile({
    super.key,
    required this.book,
    required this.onTap,
    this.width = 118,
    this.heroPrefix = 'tile',
  });

  final Book book;
  final VoidCallback onTap;
  final double width;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover.ofBook(
              book,
              width: width,
              height: width * 1.5,
              heroTag: '$heroPrefix-${book.workId}',
            ),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3),
            ),
            const SizedBox(height: 2),
            Text(
              book.authorLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
