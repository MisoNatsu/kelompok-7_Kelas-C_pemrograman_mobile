import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(appUserProvider).value;
    final favCount = ref.watch(favoritesProvider).value?.length ?? 0;
    final notif = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: me == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Text(me.displayName.initials,
                            style: context.text.headlineSmall),
                      ),
                      const SizedBox(height: 12),
                      Text(me.displayName, style: context.text.titleLarge),
                      Text(me.email, style: TextStyle(color: context.colors.outline)),
                      const SizedBox(height: 8),
                      Chip(
                        avatar: Icon(
                          me.isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                          size: 18,
                        ),
                        label: Text(me.role.label),
                        backgroundColor: me.isAdmin
                            ? context.colors.primaryContainer
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bookmark_rounded),
                        title: const Text('Buku favorit'),
                        trailing: Text('$favCount', style: context.text.titleMedium),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text('Bergabung'),
                        trailing: Text(me.createdAt?.formatted ?? '-'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: const Text('UID'),
                        subtitle: Text(me.uid, style: context.text.labelSmall),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Notifikasi', style: context.text.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Uji notifikasi lokal'),
                        subtitle: const Text('Menampilkan notifikasi contoh di perangkat ini'),
                        onTap: () async {
                          await notif.showTest();
                          if (context.mounted) context.showSnack('Notifikasi uji dikirim');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.topic_outlined),
                        title: const Text('Berlangganan topik "pengumuman"'),
                        subtitle: const Text('Terima push notification saat admin membuat pengumuman'),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                        onTap: () async {
                          await notif.subscribeAnnouncements();
                          if (context.mounted) context.showSnack('Berlangganan topik pengumuman');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.key_outlined),
                        title: const Text('Salin token FCM (untuk uji dari Firebase Console)'),
                        onTap: () async {
                          final token = await notif.getToken();
                          if (!context.mounted) return;
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Token FCM'),
                              content: SelectableText(token ?? 'Token belum tersedia'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tutup')),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: context.colors.error,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar dari akun?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Keluar')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref.read(authControllerProvider.notifier).signOut();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Pustakaku · data buku dari Open Library (openlibrary.org)',
                    style: context.text.labelSmall?.copyWith(color: context.colors.outline),
                  ),
                ),
              ],
            ),
    );
  }
}
