import 'package:flutter/foundation.dart';

/// Advanced Dart: mixin untuk membagikan perilaku lintas class
/// tanpa pewarisan tunggal.

mixin LoggerMixin {
  String get tag => runtimeType.toString();

  void log(Object? message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }
}

/// Kumpulan validator form yang bisa di-mixin ke State/Notifier mana pun.
mixin ValidatorsMixin {
  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w\.\-+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Kata sandi wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  String? validateRequired(String? value, {String label = 'Kolom ini'}) =>
      (value?.trim().isEmpty ?? true) ? '$label wajib diisi' : null;
}
