import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'theme.dart';

/// Advanced Dart: extension methods menambah fungsi ke tipe yang sudah ada
/// tanpa membuat subclass.

extension StringX on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int max, {String ellipsis = '…'}) =>
      length <= max ? this : '${substring(0, max).trimRight()}$ellipsis';

  bool get isValidEmail =>
      RegExp(r'^[\w\.\-+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(trim());

  /// Inisial nama, misal "Isyraq Awwal" -> "IA".
  String get initials {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}

extension DateTimeX on DateTime {
  String get formatted => DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(this);

  /// "baru saja", "5 menit lalu", "2 hari lalu", dst.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    // Pattern matching dengan guard clause (`when`).
    return switch (diff) {
      Duration(inSeconds: final s) when s < 60 => 'baru saja',
      Duration(inMinutes: final m) when m < 60 => '$m menit lalu',
      Duration(inHours: final h) when h < 24 => '$h jam lalu',
      Duration(inDays: final d) when d < 7 => '$d hari lalu',
      _ => formatted,
    };
  }
}

extension IterableX<T> on Iterable<T> {
  /// Menyisipkan `separator` di antara elemen (berguna untuk Column/Row).
  Iterable<T> separatedBy(T separator) sync* {
    var first = true;
    for (final item in this) {
      if (!first) yield separator;
      yield item;
      first = false;
    }
  }

  Iterable<T> distinctBy<K>(K Function(T) key) {
    final seen = <K>{};
    return where((e) => seen.add(key(e)));
  }
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  /// Token warna tambahan (kertas, kuningan, garis, palet sampul).
  AppPalette get palette => theme.extension<AppPalette>() ?? AppPalette.light;

  void showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? colors.error : null,
        ),
      );
  }
}
