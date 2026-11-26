import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../models/book.dart';
import '../services/cover_cache_manager.dart';

/// Sampul buku dengan bayangan. Bila gambar tidak ada atau masih dimuat,
/// tampil sampul cadangan berwarna berisi judul dan penulis, bukan kotak abu-abu.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    required this.title,
    this.author,
    this.width = 72,
    this.height = 108,
    this.heroTag,
    this.elevated = true,
  });

  BookCover.ofBook(
    Book book, {
    Key? key,
    CoverSize size = CoverSize.medium,
    double width = 72,
    double height = 108,
    Object? heroTag,
    bool elevated = true,
  }) : this(
          key: key,
          url: book.coverUrl(size),
          title: book.title,
          author: book.authors.isEmpty ? null : book.authors.first,
          width: width,
          height: height,
          heroTag: heroTag,
          elevated: elevated,
        );

  final String? url;
  final String title;
  final String? author;
  final double width;
  final double height;
  final Object? heroTag;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(width >= 100 ? 8 : 5);
    final fallback = _FallbackCover(title: title, author: author, width: width, height: height);

    Widget child = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: width >= 100 ? 26 : 12,
                  offset: Offset(0, width >= 100 ? 14 : 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: url == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: url!,
                cacheManager: CoverCacheManager.instance,
                width: width,
                height: height,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
    if (heroTag != null) child = Hero(tag: heroTag!, child: child);
    return child;
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({
    required this.title,
    required this.author,
    required this.width,
    required this.height,
  });

  final String title;
  final String? author;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final small = width < 70;
    return Container(
      width: width,
      height: height,
      color: p.coverFor(title),
      padding: EdgeInsets.all(small ? 6 : width * 0.1),
      child: small
          ? Center(
              child: Icon(Icons.menu_book_rounded, color: const Color(0xFFF5EFE3).withValues(alpha: 0.8)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.serif,
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.125,
                    height: 1.12,
                    color: const Color(0xFFF5EFE3),
                  ),
                ),
                if (author != null)
                  Text(
                    author!.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (width * 0.075).clamp(8, 11).toDouble(),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEADFC9),
                    ),
                  ),
              ],
            ),
    );
  }
}
