import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/mixins.dart';

/// Handler saat pesan FCM datang ketika aplikasi di background/terminated.
/// Wajib fungsi top-level dan diberi anotasi `vm:entry-point`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Di background, Android menampilkan notifikasi secara otomatis
  // bila payload berisi blok `notification`. Cukup catat log di sini.
  debugPrint('[FCM background] ${message.messageId}: ${message.notification?.title}');
}

/// Push Notifications: Firebase Cloud Messaging + flutter_local_notifications
/// (untuk menampilkan notifikasi saat aplikasi sedang terbuka / foreground).
final class NotificationService with LoggerMixin {
  NotificationService._();
  static final instance = NotificationService._();

  static const topicAnnouncements = 'pengumuman';

  /// Ikon status bar Android harus siluet putih bertransparansi;
  /// ikon peluncur berwarna akan tampil sebagai kotak putih.
  static const _smallIcon = '@drawable/ic_stat_pustakaku';
  static const _channel = AndroidNotificationChannel(
    'pengumuman_channel',
    'Pengumuman',
    description: 'Notifikasi pengumuman dari admin Pustakaku',
    importance: Importance.high,
  );

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  /// Stream pesan yang membuka aplikasi (tap notifikasi). UI bisa
  /// mendengarkannya untuk navigasi ke halaman Pengumuman.
  final _openedController = ValueNotifier<RemoteMessage?>(null);
  ValueListenable<RemoteMessage?> get openedMessage => _openedController;

  bool _initialized = false;

  /// false bila init() belum/tidak dijalankan (mode demo atau web).
  bool get isReady => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Minta izin (iOS & Android 13+).
    final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
    log('Izin notifikasi: ${settings.authorizationStatus}');

    // 2. Siapkan notifikasi lokal (foreground).
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) =>
          _openedController.value = const RemoteMessage(data: {'route': 'announcements'}),
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS: tampilkan banner walau app di foreground.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Pesan saat foreground -> tampilkan via notifikasi lokal.
    FirebaseMessaging.onMessage.listen(_showLocal);

    // 4. Pesan yang di-tap saat background / terminated.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _openedController.value = m);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _openedController.value = initial;
  }

  /// Token registrasi FCM perangkat ini. Dipakai untuk "Send test message"
  /// di Firebase Console dan disimpan ke `users/{uid}.fcmToken`.
  /// (`getToken` ditandai deprecated di firebase_messaging 17 karena Firebase
  /// beralih ke Installation ID lewat `register()`/`onRegistered`, namun
  /// token masih merupakan cara yang didukung Firebase Console saat ini.)
  Future<String?> getToken() async {
    // ignore: deprecated_member_use
    final token = await _fcm.getToken();
    log('FCM token: $token');
    return token;
  }

  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// API baru FCM: mendaftarkan instance aplikasi dan memberikan
  /// Firebase Installation ID (FID) untuk direct-send.
  Future<void> register() => _fcm.register();
  Stream<String> get onRegistered => _fcm.onRegistered;

  Future<void> subscribeAnnouncements() => _fcm.subscribeToTopic(topicAnnouncements);
  Future<void> unsubscribeAnnouncements() => _fcm.unsubscribeFromTopic(topicAnnouncements);

  Future<void> _showLocal(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title ?? message.data['title'] as String?;
    final body = n?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: _smallIcon,
          color: const Color(0xFF1F4D3A),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Notifikasi lokal langsung dari aplikasi (dipakai untuk tombol uji di Profil).
  Future<void> showTest() async {
    if (!_initialized) {
      // Mode demo: siapkan hanya plugin notifikasi lokal (tanpa FCM).
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_smallIcon),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
    return _showLocal(
        const RemoteMessage(
          data: {
            'title': 'Pustakaku',
            'body': 'Notifikasi berfungsi! Pengumuman admin akan muncul seperti ini.',
          },
        ),
      );
  }
}
