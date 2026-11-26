import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/app_user.dart';
import 'service_providers.dart';

/// Status login Firebase (null = belum login). Reaktif: semua widget yang
/// `watch` provider ini otomatis rebuild saat login/logout.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

/// Profil pengguna dari Firestore (berisi role). Bergantung pada authState.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).watchUser(user.uid);
});

/// Authorization di sisi UI: true hanya bila role == admin.
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(appUserProvider).value?.isAdmin ?? false,
);

/// Aksi login/registrasi/reset. State-nya `AsyncValue<void>` sehingga form
/// bisa menampilkan loading & pesan error secara deklaratif.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn(String email, String password) => _run(
        () => ref.read(authServiceProvider).signIn(email, password),
      );

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(
        () => ref.read(authServiceProvider).register(
              name: name,
              email: email,
              password: password,
            ),
      );

  Future<bool> resetPassword(String email) => _run(
        () => ref.read(authServiceProvider).resetPassword(email),
      );

  Future<void> signOut() => ref.read(authServiceProvider).signOut();

  /// Generic helper: menjalankan aksi yang mengembalikan `Result<T>` dan
  /// memetakannya ke AsyncValue.
  Future<bool> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (msg) => AsyncError<void>(msg, StackTrace.current),
    );
    return result.isSuccess;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
