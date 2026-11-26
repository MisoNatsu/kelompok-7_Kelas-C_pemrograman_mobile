import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/open_library_api.dart';

/// Dependency injection sederhana lewat Provider. Di unit test, provider ini
/// bisa di-override dengan mock (`ProviderScope(overrides: [...])`).

final openLibraryApiProvider = Provider<OpenLibraryApi>((ref) {
  final api = OpenLibraryApi();
  ref.onDispose(api.dispose);
  return api;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);
