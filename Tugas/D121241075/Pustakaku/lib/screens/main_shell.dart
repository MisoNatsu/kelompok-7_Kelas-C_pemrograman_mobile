import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import 'admin_screen.dart';
import 'announcements_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Kerangka utama dengan bottom navigation. Tab "Admin" hanya muncul bila
/// pengguna ber-role admin (Authorization di UI).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Jika aplikasi dibuka dari tap notifikasi, langsung ke tab Pengumuman.
    final notif = ref.read(notificationServiceProvider);
    notif.openedMessage.addListener(_onNotificationOpened);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onNotificationOpened());
  }

  @override
  void dispose() {
    ref.read(notificationServiceProvider).openedMessage.removeListener(_onNotificationOpened);
    super.dispose();
  }

  void _onNotificationOpened() {
    final message = ref.read(notificationServiceProvider).openedMessage.value;
    if (message != null && mounted) setState(() => _index = 2);
  }

  @override
  Widget build(BuildContext context) {
    // Daftarkan token FCM & subscribe topic begitu masuk beranda.
    ref.watch(fcmRegistrationProvider(widget.uid));
    final isAdmin = ref.watch(isAdminProvider);

    final tabs = <({Widget page, NavigationDestination dest})>[
      (
        page: const HomeScreen(),
        dest: const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Jelajah'),
      ),
      (
        page: const FavoritesScreen(),
        dest: const NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Favorit'),
      ),
      (
        page: const AnnouncementsScreen(),
        dest: const NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Pengumuman'),
      ),
      if (isAdmin)
        (
          page: const AdminScreen(),
          dest: const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Admin'),
        ),
      (
        page: const ProfileScreen(),
        dest: const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil'),
      ),
    ];
    final index = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: [for (final t in tabs) t.page]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [for (final t in tabs) t.dest],
      ),
    );
  }
}
