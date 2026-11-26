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
  });

  final String workId; // contoh: OL45804W
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final double? rating;
  final int? pages;
  final List<String> subjects;

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
      };

  factory Book.fromMap(Json map) => Book(
        workId: map['workId'] as String,
        title: map['title'] as String,
        authors: (map['authors'] as List?)?.cast<String>() ?? const [],
        firstPublishYear: map['firstPublishYear'] as int?,
        coverId: map['coverId'] as int?,
        rating: (map['rating'] as num?)?.toDouble(),
        pages: map['pages'] as int?,
      );

  String get authorLabel =>
      authors.isEmpty ? 'Penulis tidak diketahui' : authors.take(2).join(', ');

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
