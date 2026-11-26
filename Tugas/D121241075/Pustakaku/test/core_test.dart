import 'package:flutter_test/flutter_test.dart';
import 'package:pustakaku/core/extensions.dart';
import 'package:pustakaku/core/result.dart';
import 'package:pustakaku/models/book.dart';
import 'package:pustakaku/services/cover_cache_manager.dart';

void main() {
  group('Result<T> (sealed class)', () {
    test('map hanya mengubah Success', () {
      const Result<int> ok = Result.success(2);
      const Result<int> err = Result.failure('gagal');

      expect(ok.map((v) => v * 10).getOrElse(0), 20);
      expect(err.map((v) => v * 10).getOrElse(-1), -1);
    });

    test('guard membungkus exception menjadi Failure', () async {
      final r = await guard<int>(() async => throw const FormatException('x'));
      expect(r, isA<Failure<int>>());
      expect(r.when(success: (_) => 'ok', failure: (m) => m), contains('FormatException'));
    });

    test('getOrThrow melempar AppException dengan pesan bersih', () {
      const Result<int> err = Result.failure('Tidak ada koneksi');
      expect(
        () => err.getOrThrow(),
        throwsA(predicate((e) => e.toString() == 'Tidak ada koneksi')),
      );
    });
  });

  group('Extension methods', () {
    test('StringX', () {
      expect('isyraq'.capitalized, 'Isyraq');
      expect('Isyraq Awwal'.initials, 'IA');
      expect('abcdefghij'.truncate(5), 'abcde…');
      expect('a@b.co'.isValidEmail, isTrue);
      expect('bukan-email'.isValidEmail, isFalse);
    });

    test('DateTimeX.timeAgo', () {
      final now = DateTime.now();
      expect(now.timeAgo, 'baru saja');
      expect(now.subtract(const Duration(minutes: 5)).timeAgo, '5 menit lalu');
      expect(now.subtract(const Duration(hours: 3)).timeAgo, '3 jam lalu');
      expect(now.subtract(const Duration(days: 2)).timeAgo, '2 hari lalu');
    });

    test('IterableX', () {
      expect([1, 2, 3].separatedBy(0).toList(), [1, 0, 2, 0, 3]);
      expect(['a', 'A', 'b'].distinctBy((s) => s.toLowerCase()).toList(), ['a', 'b']);
    });
  });

  group('Model Book', () {
    test('fromJson membaca format Open Library', () {
      final book = Book.fromJson({
        'key': '/works/OL45804W',
        'title': 'Fantastic Mr Fox',
        'author_name': ['Roald Dahl'],
        'first_publish_year': 1970,
        'cover_i': 6498519,
        'ratings_average': 4.2,
      });
      expect(book.workId, 'OL45804W');
      expect(book.authorLabel, 'Roald Dahl');
      expect(book.coverUrl(), 'https://covers.openlibrary.org/b/id/6498519-M.jpg');
      expect(book.coverUrl(CoverSize.large), endsWith('-L.jpg'));
    });

    test('BookDetail menangani description String maupun objek', () {
      final a = BookDetail.fromJson({'key': '/works/X', 'description': 'teks'});
      final b = BookDetail.fromJson({
        'key': '/works/X',
        'description': {'type': '/type/text', 'value': 'objek'},
      });
      final c = BookDetail.fromJson({'key': '/works/X'});
      expect(a.description, 'teks');
      expect(b.description, 'objek');
      expect(c.description, 'Tidak ada deskripsi.');
    });

    test('Comparable: rating tertinggi lebih dulu', () {
      final books = [
        const Book(workId: 'a', title: 'A', authors: [], rating: 3),
        const Book(workId: 'b', title: 'B', authors: [], rating: 5),
      ]..sort();
      expect(books.first.workId, 'b');
    });
  });

  group('Validasi sampul', () {
    test('menolak isi kosong dan HTML, menerima JPEG/PNG', () {
      expect(looksLikeImage(const []), isFalse);
      expect(looksLikeImage('<!DOCTYPE html><html>'.codeUnits), isFalse);
      expect(looksLikeImage([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(20, 0)]), isTrue);
      expect(looksLikeImage([0x89, 0x50, 0x4E, 0x47, ...List.filled(20, 0)]), isTrue);
    });
  });
}
