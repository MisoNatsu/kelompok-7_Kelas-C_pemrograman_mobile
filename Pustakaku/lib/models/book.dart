typedef Json = Map<String, dynamic>;

/// Buku hasil pencarian dari Open Library (endpoint /search.json & /trending).
final class Book implements Comparable<Book> {
  const Book({
    required this.workId,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverId,
    this.rating,
    this.pages,
    this.subjects = const [],
    this.ebookAccess = EbookAccess.unavailable,
    this.iaId,
  });

  final String workId; // contoh: OL45804W
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final double? rating;
  final int? pages;
  final List<String> subjects;
  final EbookAccess ebookAccess;

  /// ID edisi di Internet Archive yang bisa dibaca atau dipinjam.
  final String? iaId;

  factory Book.fromJson(Json json) {
    final key = (json['key'] as String? ?? '').split('/').last;
    return Book(
      workId: key,
      title: json['title'] as String? ?? 'Tanpa judul',
      authors: (json['author_name'] as List?)?.cast<String>() ?? const [],
      firstPublishYear: json['first_publish_year'] as int?,
      coverId: json['cover_i'] as int?,
      rating: (json['ratings_average'] as num?)?.toDouble(),
      pages: json['number_of_pages_median'] as int?,
      subjects: (json['subject'] as List?)?.cast<String>().take(8).toList() ??
          const [],
      ebookAccess: EbookAccess.fromApi(json['ebook_access'] as String?),
      iaId: json['lending_identifier_s'] as String?,
    );
  }

  /// Untuk disimpan ke Firestore sebagai favorit.
  Json toMap() => {
        'workId': workId,
        'title': title,
        'authors': authors,
        'firstPublishYear': firstPublishYear,
        'coverId': coverId,
        'rating': rating,
        'pages': pages,
        'ebookAccess': ebookAccess.name,
        'iaId': iaId,
      };

  factory Book.fromMap(Json map) => Book(
        workId: map['workId'] as String,
        title: map['title'] as String,
        authors: (map['authors'] as List?)?.cast<String>() ?? const [],
        firstPublishYear: map['firstPublishYear'] as int?,
        coverId: map['coverId'] as int?,
        rating: (map['rating'] as num?)?.toDouble(),
        pages: map['pages'] as int?,
        ebookAccess: EbookAccess.values.asNameMap()[map['ebookAccess']] ??
            EbookAccess.unavailable,
        iaId: map['iaId'] as String?,
      );

  String get authorLabel =>
      authors.isEmpty ? 'Penulis tidak diketahui' : authors.take(2).join(', ');

  /// Status baca dari Open Library, dipakai halaman detail.
  ReadingInfo get reading => (access: ebookAccess, iaId: iaId);

  String? coverUrl([CoverSize size = CoverSize.medium]) =>
      coverId == null ? null : size.url(coverId!);

  @override
  int compareTo(Book other) =>
      (other.rating ?? 0).compareTo(rating ?? 0); // rating tertinggi dulu

  @override
  bool operator ==(Object other) => other is Book && other.workId == workId;

  @override
  int get hashCode => workId.hashCode;
}

/// Ketersediaan e-book dari field `ebook_access` Open Library.
enum EbookAccess {
  /// Domain publik: bisa dibaca gratis tanpa login.
  public('Gratis dibaca'),

  /// Harus dipinjam dengan akun Internet Archive.
  borrowable('Bisa dipinjam'),

  /// `printdisabled`, `no_ebook`, atau tidak diketahui.
  unavailable('Belum bisa dibaca');

  const EbookAccess(this.label);
  final String label;

  static EbookAccess fromApi(String? value) => switch (value) {
        'public' => EbookAccess.public,
        'borrowable' => EbookAccess.borrowable,
        _ => EbookAccess.unavailable,
      };
}

/// Record: status baca sebuah karya dan edisi yang dipakai.
typedef ReadingInfo = ({EbookAccess access, String? iaId});

extension ReadingInfoX on ReadingInfo {
  /// Halaman yang dibuka tombol baca/pinjam, atau null bila tidak ada.
  Uri? url(String workId) => switch (this) {
        (access: EbookAccess.public, iaId: final String id) =>
          Uri.https('archive.org', '/details/$id', {'view': 'theater'}),
        // Edisi pinjaman bisa berbahasa lain, jadi biarkan pengguna memilih
        // edisinya sendiri di halaman karya Open Library.
        (access: EbookAccess.borrowable, iaId: _) =>
          Uri.https('openlibrary.org', '/works/$workId'),
        _ => null,
      };
}

/// Enhanced enum: enum dengan field & method (Dart 2.17+).
enum CoverSize {
  small('S'),
  medium('M'),
  large('L');

  const CoverSize(this.code);
  final String code;

  String url(int coverId) =>
      'https://covers.openlibrary.org/b/id/$coverId-$code.jpg';
}

/// Detail dari endpoint /works/{id}.json.
final class BookDetail {
  const BookDetail({
    required this.workId,
    required this.title,
    required this.description,
    required this.subjects,
    required this.coverIds,
    this.firstPublishDate,
  });

  final String workId;
  final String title;
  final String description;
  final List<String> subjects;
  final List<int> coverIds;
  final String? firstPublishDate;

  factory BookDetail.fromJson(Json json) {
    // `description` bisa berupa String ATAU {"type": "/type/text", "value": "..."}
    final description = switch (json['description']) {
      final String s => s,
      {'value': final String v} => v,
      _ => 'Tidak ada deskripsi.',
    };
    return BookDetail(
      workId: (json['key'] as String? ?? '').split('/').last,
      title: json['title'] as String? ?? '',
      description: description,
      subjects: (json['subjects'] as List?)?.cast<String>().take(12).toList() ??
          const [],
      coverIds: (json['covers'] as List?)
              ?.whereType<int>()
              .where((id) => id > 0)
              .toList() ??
          const [],
      firstPublishDate: json['first_publish_date'] as String?,
    );
  }
}

/// Record (Dart 3): hasil pencarian = daftar buku + total ditemukan.
typedef SearchPage = ({List<Book> books, int totalFound});
