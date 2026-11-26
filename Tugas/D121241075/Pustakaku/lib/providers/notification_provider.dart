import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'service_providers.dart';

/// Mendaftarkan perangkat untuk push notification setelah login:
/// simpan token FCM ke `users/{uid}` dan subscribe topic `pengumuman`.
/// Di-`watch` sekali di MainShell; key = uid agar dijalankan ulang bila ganti akun.
final fcmRegistrationProvider =
    FutureProvider.family<void, String>((ref, uid) async {
  final notif = ref.watch(notificationServiceProvider);
  final db = ref.watch(firestoreServiceProvider);
  if (!notif.isReady) return; // mode demo / web: FCM tidak aktif

  final token = await notif.getToken();
  if (token != null) await db.saveFcmToken(uid, token);
  await notif.subscribeAnnouncements();

  // Simpan ulang bila token berganti, dan simpan FID dari API register().
  final subs = [
    notif.onTokenRefresh.listen((t) => db.saveFcmToken(uid, t)),
    notif.onRegistered.listen((fid) => db.saveInstallationId(uid, fid)),
  ];
  await notif.register();
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
  });
});
