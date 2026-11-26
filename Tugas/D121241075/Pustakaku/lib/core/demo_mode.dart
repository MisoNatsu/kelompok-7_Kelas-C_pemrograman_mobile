import '../firebase_options.dart';

/// Mode demo aktif selama `firebase_options.dart` masih memakai projectId
/// `demo-*` (belum dijalankan `flutterfire configure`). Pada mode ini aplikasi
/// terhubung ke Firebase Local Emulator Suite, bukan server Firebase.
///
/// Dipisahkan dari `firebase_options.dart` karena file itu ditimpa setiap kali
/// `flutterfire configure` dijalankan.
bool get isDemoMode =>
    DefaultFirebaseOptions.currentPlatform.projectId.startsWith('demo-');
