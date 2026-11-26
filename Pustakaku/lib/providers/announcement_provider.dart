import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../models/app_user.dart';
import 'service_providers.dart';

final announcementsProvider = StreamProvider<List<Announcement>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAnnouncements(),
);

/// Daftar seluruh pengguna — hanya boleh dibaca admin (Firestore rules
/// akan menolak pengguna biasa, sehingga stream ini error untuk mereka).
final allUsersProvider = StreamProvider<List<AppUser>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllUsers(),
);
