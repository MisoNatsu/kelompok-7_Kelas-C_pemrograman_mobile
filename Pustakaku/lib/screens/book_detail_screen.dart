import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/extensions.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../providers/providers.dart';
import '../widgets/book_cover.dart';
import '../widgets/empty_state.dart';
import '../widgets/rating_stars.dart';
import '../widgets/skeleton.dart';
import 'reader_screen.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.book, this.heroTag});

  final Book book;

  /// Harus sama dengan tag Hero di layar asal agar sampul beranimasi.
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final detail = ref.watch(bookDetailProvider(book.workId));
    final isFav = ref.watch(isFavoriteProvider(book.workId));
    final reviews = ref.watch(reviewsProvider(book.workId));
    final avg = ref.watch(averageRatingProvider(book.workId));
    final me = ref.watch(appUserProvider).value;
    final reviewCount = reviews.value?.length ?? 0;
    // Data dari daftar dipakai langsung; favorit lama ditanyakan ke Open Library.
    final ReadingInfo? reading = book.ebookAccess != EbookAccess.unavailable
        ? book.reading
        : ref.watch(readingInfoProvider(book.workId)).value;
    final readUrl = reading?.url(book.workId);

    Future<void> toggleFav() async {
      final r = await ref.read(toggleFavoriteProvider)(book);
      if (!context.mounted) return;
      r.when(
        success: (_) => context.showSnack(isFav ? 'Dihapus dari favorit' : 'Disimpan ke favorit'),
        failure: (m) => context.showSnack(m, error: true),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: p.paperDeep,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RoundButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Kembali',
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          _RoundButton(
                            icon: isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                            onTap: toggleFav,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BookCover.ofBook(
                        book,
                        size: CoverSize.large,
                        width: 150,
                        height: 225,
                        heroTag: heroTag ?? 'cover-${book.workId}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList.list(
              children: [
                Text(book.title, style: context.text.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  book.authorLabel,
                  style: context.text.bodyLarge?.copyWith(color: p.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _StatsRow(
                  stats: [
                    (book.firstPublishYear?.toString() ?? '-', 'Terbit'),
                    (book.pages?.toString() ?? '-', 'Halaman'),
                    (
                      avg != null ? avg.toStringAsFixed(1) : '$reviewCount',
                      avg != null ? 'Rating · $reviewCount ulasan' : 'Ulasan',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (reading != null && readUrl != null) ...[
                  _ReadAction(book: book, access: reading.access, url: readUrl),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: isFav
                          ? OutlinedButton.icon(
                              onPressed: toggleFav,
                              icon: const Icon(Icons.bookmark_rounded),
                              label: const Text('Tersimpan di rak'),
                            )
                          : FilledButton.icon(
                              onPressed: toggleFav,
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: const Text('Simpan ke Favorit'),
                            ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: me == null
                            ? null
                            : () => _showReviewSheet(context, ref, me.uid, me.displayName),
                        child: const Icon(Icons.rate_review_outlined, semanticLabel: 'Tulis ulasan'),
                      ),
                    ),
                  ],
                ),
                if (reading?.access == EbookAccess.unavailable) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: p.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Belum ada e-book yang bisa dibaca untuk buku ini.',
                          style: TextStyle(fontSize: 13, color: p.muted),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                const SectionHeader('Tentang buku ini'),
                const SizedBox(height: 8),
                detail.when(
                  loading: () => const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(),
                      SizedBox(height: 8),
                      Skeleton(),
                      SizedBox(height: 8),
                      Skeleton(width: 200),
                    ],
                  ),
                  error: (e, _) => Text('$e', style: TextStyle(color: context.colors.error)),
                  data: (d) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExpandableText(d.description),
                      if (d.subjects.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in d.subjects.take(8))
                              Chip(
                                label: Text(s.truncate(28)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  'Ulasan pembaca',
                  trailing: avg == null
                      ? null
                      : Row(children: [
                          RatingStars(rating: avg, size: 16),
                          const SizedBox(width: 6),
                          Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                ),
                const SizedBox(height: 10),
                reviews.when(
                  loading: () => const Skeleton(height: 72, radius: 16),
                  error: (e, _) => Text('$e'),
                  data: (list) => list.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Belum ada ulasan', style: context.text.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Jadilah pembaca pertama yang memberi pendapat.',
                                  style: TextStyle(color: p.muted),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (final r in list)
                              _ReviewTile(
                                review: r,
                                // Authorization: pemilik ulasan ATAU admin boleh menghapus.
                                canDelete: me != null && (me.uid == r.uid || me.isAdmin),
                                onDelete: () async {
                                  final res = await ref.read(firestoreServiceProvider).deleteReview(r.id);
                                  if (!context.mounted) return;
                                  res.when(
                                    success: (_) => context.showSnack('Ulasan dihapus'),
                                    failure: (m) => context.showSnack(m, error: true),
                                  );
                                },
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReviewSheet(BuildContext context, WidgetRef ref, String uid, String name) async {
    var rating = 5;
    final text = TextEditingController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ulas buku ini', style: ctx.text.titleLarge),
              const SizedBox(height: 4),
              Text(book.title.truncate(60), style: TextStyle(color: ctx.palette.muted)),
              const SizedBox(height: 16),
              Center(
                child: RatingStars(
                  rating: rating.toDouble(),
                  size: 38,
                  onChanged: (v) => setState(() => rating = v),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: text,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Bagaimana pendapatmu tentang buku ini?'),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kirim ulasan')),
            ],
          ),
        ),
      ),
    );
    if (submitted != true || text.text.trim().isEmpty) return;

    final res = await ref.read(firestoreServiceProvider).addReview(Review(
          id: '',
          bookId: book.workId,
          uid: uid,
          authorName: name,
          rating: rating,
          text: text.text.trim(),
        ));
    if (!context.mounted) return;
    res.when(
      success: (_) => context.showSnack('Terima kasih atas ulasanmu!'),
      failure: (m) => context.showSnack(m, error: true),
    );
  }
}

/// Tombol baca (buku domain publik) atau pinjam (perlu akun Internet Archive).
class _ReadAction extends StatelessWidget {
  const _ReadAction({required this.book, required this.access, required this.url});
  final Book book;
  final EbookAccess access;
  final Uri url;

  Future<void> _openExternal(BuildContext context) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) context.showSnack('Browser tidak dapat dibuka', error: true);
  }

  void _read(BuildContext context) {
    // WebView tidak tersedia di web, jadi buka tab baru.
    if (kIsWeb) {
      _openExternal(context);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReaderScreen(title: book.title, url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (button, caption) = switch (access) {
      EbookAccess.public => (
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: p.accent, foregroundColor: p.onPrimary),
            onPressed: () => _read(context),
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('Baca gratis'),
          ),
          'Domain publik, dibaca lewat Internet Archive',
        ),
      _ => (
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () => _openExternal(context),
            icon: const Icon(Icons.local_library_outlined),
            label: const Text('Pinjam di Open Library'),
          ),
          'Perlu akun Internet Archive untuk meminjam',
        ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 6),
        Text(caption, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: p.muted)),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filled(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: context.palette.card,
          foregroundColor: context.palette.ink,
          minimumSize: const Size(44, 44),
        ),
        icon: Icon(icon),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  /// Record (nilai, label).
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (final (i, (value, label)) in stats.indexed) ...[
                if (i > 0) VerticalDivider(color: p.line, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      Text(value, style: context.text.titleLarge?.copyWith(fontSize: 19)),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: p.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.canDelete, required this.onDelete});
  final Review review;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: p.primarySoft,
                foregroundColor: p.primary,
                child: Text(review.authorName.initials, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName, style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Row(children: [
                      RatingStars(rating: review.rating.toDouble(), size: 15),
                      const SizedBox(width: 8),
                      Text(
                        review.createdAt?.timeAgo ?? 'mengirim…',
                        style: TextStyle(fontSize: 12, color: p.muted),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(review.text),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: p.muted,
                  tooltip: 'Hapus ulasan',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);
  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final long = widget.text.length > 280;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _expanded || !long ? widget.text : widget.text.truncate(280),
          style: context.text.bodyLarge?.copyWith(fontSize: 15),
        ),
        if (long)
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Lebih sedikit' : 'Selengkapnya'),
          ),
      ],
    );
  }
}
