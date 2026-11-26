import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'core/demo_mode.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (konfigurasi dihasilkan `flutterfire configure`).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1b. Mode demo: arahkan Auth & Firestore ke Local Emulator Suite.
  if (isDemoMode) {
    // Emulator Android memakai 10.0.2.2 untuk mencapai localhost host.
    final host = !kIsWeb && Platform.isAndroid ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    debugPrint('[Pustakaku] MODE DEMO: memakai Firebase Emulator di $host');
  }

  // 2. Push notification: handler background harus didaftarkan sebelum runApp.
  //    FCM membutuhkan proyek Firebase sungguhan & (di web) service worker,
  //    jadi dilewati pada mode demo / web.
  if (!isDemoMode && !kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init();
  }

  // 3. Format tanggal Bahasa Indonesia.
  await initializeDateFormatting('id_ID');

  runApp(const ProviderScope(child: PustakakuApp()));
}

class PustakakuApp extends StatelessWidget {
  const PustakakuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pustakaku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthGate(),
      );
}

/// Memilih layar berdasarkan status login (reaktif via Riverpod).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Gagal memuat sesi: $e'))),
      data: (user) =>
          user == null ? const LoginScreen() : MainShell(key: ValueKey(user.uid), uid: user.uid),
    );
  }
}
