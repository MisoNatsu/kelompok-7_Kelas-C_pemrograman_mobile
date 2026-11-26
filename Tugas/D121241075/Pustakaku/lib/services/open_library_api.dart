import 'dart:convert';

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:http/http.dart' as http;

import '../core/mixins.dart';
import '../core/result.dart';
import '../models/book.dart';

/// Klien untuk **Open Library API** (https://openlibrary.org/developers/api)
/// — API open source milik Internet Archive, gratis, tanpa API key.
///
/// Advanced Dart yang dipakai di sini:
/// - generic method `_get<T>` dengan parser sebagai parameter fungsi,
/// - `compute` menjalankan `jsonDecode` di isolate terpisah agar UI tidak macet,
/// - sealed `Result<T>` sebagai nilai balik.
final class OpenLibraryApi with LoggerMixin {
  OpenLibraryApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _host = 'openlibrary.org';
  static const _fields =
      'key,title,author_name,first_publish_year,cover_i,subject,'
      'ratings_average,number_of_pages_median';

  Future<Result<T>> _get<T>(
    Uri uri,
    T Function(Json json) parse,
  ) async {
    log('GET $uri');
    return guard(
      () async {
        // Browser melarang header User-Agent kustom, jadi hanya di mobile.
        final res = await _client
            .get(uri, headers: {
              if (!kIsWeb) 'User-Agent': 'Pustakaku/1.0 (Flutter)',
            })
            .timeout(const Duration(seconds: 20));
        if (res.statusCode != 200) {
          throw http.ClientException('HTTP ${res.statusCode}', uri);
        }
        // Parsing JSON besar di background isolate.
        final json = await compute(_decodeJson, res.body);
        return parse(json);
      },
      onError: (e) => switch (e) {
        http.ClientException() => 'Server Open Library bermasalah ($e).',
        FormatException() => 'Respons tidak valid dari server.',
        _ => 'Tidak dapat terhubung. Periksa koneksi internet.',
      },
    );
  }

  /// Mencari buku. Mengembalikan record `(books, totalFound)`.
  Future<Result<SearchPage>> search(String query, {int page = 1}) {
    final uri = Uri.https(_host, '/search.json', {
      'q': query,
      'page': '$page',
      'limit': '20',
      'fields': _fields,
    });
    return _get(uri, (json) {
      final docs = (json['docs'] as List? ?? const []).cast<Json>();
      return (
        books: docs.map(Book.fromJson).where((b) => b.workId.isNotEmpty).toList(),
        totalFound: json['numFound'] as int? ?? 0,
      );
    });
  }

  /// Buku yang sedang tren hari ini (untuk beranda sebelum pengguna mencari).
  Future<Result<List<Book>>> trending() {
    final uri = Uri.https(_host, '/trending/daily.json', {'limit': '20'});
    return _get(uri, (json) {
      final works = (json['works'] as List? ?? const []).cast<Json>();
      return works.map(Book.fromJson).where((b) => b.workId.isNotEmpty).toList();
    });
  }

  /// Detail karya (deskripsi, subjek, sampul).
  Future<Result<BookDetail>> detail(String workId) {
    final uri = Uri.https(_host, '/works/$workId.json');
    return _get(uri, BookDetail.fromJson);
  }

  void dispose() => _client.close();
}

/// Fungsi top-level agar bisa dikirim ke isolate oleh `compute`.
Json _decodeJson(String body) => jsonDecode(body) as Json;
