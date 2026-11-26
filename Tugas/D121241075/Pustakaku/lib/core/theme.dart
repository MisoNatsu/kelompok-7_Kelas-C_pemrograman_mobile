import 'package:flutter/material.dart';

/// Gaya "Perpustakaan Klasik": kertas krem, hijau tua, aksen kuningan,
/// judul serif Fraunces dan teks Plus Jakarta Sans.
///
/// Warna di luar [ColorScheme] (kertas, kuningan, garis, palet sampul)
/// disimpan di [AppPalette], sebuah [ThemeExtension], sehingga mode terang
/// dan gelap tetap konsisten dan widget cukup memanggil `context.palette`.
abstract final class AppTheme {
  static const serif = 'Fraunces';
  static const sans = 'PlusJakartaSans';

  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.primary,
      secondary: p.accent,
      onSecondary: p.onPrimary,
      secondaryContainer: p.accentSoft,
      onSecondaryContainer: p.onAccentSoft,
      tertiary: p.accent,
      onTertiary: p.onPrimary,
      error: p.error,
      onError: Colors.white,
      surface: p.paper,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.card,
      surfaceContainerLow: p.card,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.paperDeep,
      surfaceContainerHighest: p.paperDeep,
      outline: p.muted,
      outlineVariant: p.line,
      shadow: Colors.black,
      inverseSurface: p.ink,
      onInverseSurface: p.paper,
      inversePrimary: p.primarySoft,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: sans,
      scaffoldBackgroundColor: p.paper,
      extensions: [p],
    );

    TextStyle? serifStyle(TextStyle? s, {double? size, FontWeight w = FontWeight.w700}) =>
        s?.copyWith(fontFamily: serif, fontWeight: w, fontSize: size, color: p.ink, height: 1.15);

    final text = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
    final textTheme = text.copyWith(
      displaySmall: serifStyle(text.displaySmall, size: 34),
      headlineLarge: serifStyle(text.headlineLarge, size: 32),
      headlineMedium: serifStyle(text.headlineMedium, size: 28),
      headlineSmall: serifStyle(text.headlineSmall, size: 24),
      titleLarge: serifStyle(text.titleLarge, size: 21),
      titleMedium: serifStyle(text.titleMedium, size: 17, w: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.5),
      bodyLarge: text.bodyLarge?.copyWith(height: 1.55),
    );

    final rounded14 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: p.paper,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.line, space: 1, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        hintStyle: TextStyle(color: p.muted),
        prefixIconColor: p.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          textStyle: const TextStyle(fontFamily: sans, fontSize: 15, fontWeight: FontWeight.w700),
          shape: rounded14,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(52, 52),
          foregroundColor: p.primary,
          side: BorderSide(color: p.lineStrong),
          textStyle: const TextStyle(fontFamily: sans, fontSize: 15, fontWeight: FontWeight.w700),
          shape: rounded14,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(fontFamily: sans, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.accentSoft,
        labelStyle: TextStyle(color: p.onAccentSoft, fontWeight: FontWeight.w600, fontFamily: sans),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        extendedTextStyle: const TextStyle(fontFamily: sans, fontWeight: FontWeight.w700),
        shape: rounded14,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primarySoft,
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: sans,
            // Bobot sama (500) untuk aktif/tidak aktif: dengan lima tab, label
            // "Pengumuman" berbobot lebih tebal terlipat dua baris. Tab aktif
            // tetap dibedakan lewat warna dan latar pil di ikon.
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: s.contains(WidgetState.selected) ? p.primary : p.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? p.primary : p.muted),
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.paper, fontFamily: sans),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.primary,
          selectedForegroundColor: p.onPrimary,
          foregroundColor: p.ink,
          side: BorderSide(color: p.lineStrong),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }
}

/// Token warna di luar ColorScheme bawaan Material.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.paper,
    required this.paperDeep,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.lineStrong,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.error,
    required this.covers,
  });

  final Color paper; // latar halaman
  final Color paperDeep; // pita latar sampul di halaman detail
  final Color card; // permukaan kartu
  final Color ink; // teks utama
  final Color muted; // teks sekunder (lolos kontras 4.5:1 di atas paper)
  final Color line; // garis tipis
  final Color lineStrong; // garis tombol outline
  final Color primary; // hijau perpustakaan
  final Color onPrimary;
  final Color primarySoft;
  final Color accent; // kuningan
  final Color accentSoft;
  final Color onAccentSoft;
  final Color error;

  /// Warna sampul cadangan saat buku tidak punya gambar sampul.
  final List<Color> covers;

  static const light = AppPalette(
    paper: Color(0xFFF5EFE3),
    paperDeep: Color(0xFFE9E0CF),
    card: Color(0xFFFFFDF8),
    ink: Color(0xFF1F2A22),
    muted: Color(0xFF5E6B62),
    line: Color(0xFFE6DCCB),
    lineStrong: Color(0xFFD3C5AE),
    primary: Color(0xFF1F4D3A),
    onPrimary: Color(0xFFF5EFE3),
    primarySoft: Color(0xFFDCE7E0),
    accent: Color(0xFF8A6420),
    accentSoft: Color(0xFFEFE6D5),
    onAccentSoft: Color(0xFF6E4F18),
    error: Color(0xFFB3261E),
    covers: [
      Color(0xFF1F4D3A),
      Color(0xFF7A2E2E),
      Color(0xFF2D3E5C),
      Color(0xFF8A6420),
      Color(0xFF5B3A6E),
      Color(0xFF3F5A3A),
    ],
  );

  static const dark = AppPalette(
    paper: Color(0xFF141814),
    paperDeep: Color(0xFF1D231E),
    card: Color(0xFF1B201C),
    ink: Color(0xFFEDE7DA),
    muted: Color(0xFFA9B0A8),
    line: Color(0xFF2C332D),
    lineStrong: Color(0xFF3B443C),
    primary: Color(0xFF9CCBB1),
    onPrimary: Color(0xFF0F2219),
    primarySoft: Color(0xFF24352B),
    accent: Color(0xFFD9B36A),
    accentSoft: Color(0xFF2E281B),
    onAccentSoft: Color(0xFFE6C88C),
    error: Color(0xFFF2B8B5),
    covers: [
      Color(0xFF2E6A51),
      Color(0xFF8C3A3A),
      Color(0xFF3B5078),
      Color(0xFF9A742C),
      Color(0xFF6C4A80),
      Color(0xFF4E6E48),
    ],
  );

  /// Warna sampul cadangan yang stabil untuk sebuah kunci (judul/id buku).
  Color coverFor(String key) => covers[key.hashCode.abs() % covers.length];

  @override
  AppPalette copyWith({Color? primary, Color? accent}) => AppPalette(
        paper: paper,
        paperDeep: paperDeep,
        card: card,
        ink: ink,
        muted: muted,
        line: line,
        lineStrong: lineStrong,
        primary: primary ?? this.primary,
        onPrimary: onPrimary,
        primarySoft: primarySoft,
        accent: accent ?? this.accent,
        accentSoft: accentSoft,
        onAccentSoft: onAccentSoft,
        error: error,
        covers: covers,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      paper: l(paper, other.paper),
      paperDeep: l(paperDeep, other.paperDeep),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccentSoft: l(onAccentSoft, other.onAccentSoft),
      error: l(error, other.error),
      covers: [for (var i = 0; i < covers.length; i++) l(covers[i], other.covers[i])],
    );
  }
}
