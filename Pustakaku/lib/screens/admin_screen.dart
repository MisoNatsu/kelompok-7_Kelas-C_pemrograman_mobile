import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../models/app_user.dart';
import '../providers/providers.dart';
import '../widgets/async_value_widget.dart';

/// Panel admin: kelola role pengguna. Layar ini hanya dapat dibuka admin
/// (tab tersembunyi untuk pengguna biasa), dan Firestore rules menolak
/// pembacaan koleksi `users` serta perubahan `role` dari non-admin.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);
    final me = ref.watch(appUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin')),
      body: AsyncValueWidget(
        value: users,
        onRetry: () => ref.invalidate(allUsersProvider),
        data: (list) {
          final admins = list.where((u) => u.isAdmin).length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _Stat(label: 'Pengguna', value: '${list.length}', icon: Icons.people_outline),
                  const SizedBox(width: 12),
                  _Stat(label: 'Admin', value: '$admins', icon: Icons.shield_outlined),
                ],
              ),
              const SizedBox(height: 24),
              Text('Kelola peran', style: context.text.titleMedium),
              const SizedBox(height: 8),
              for (final u in list)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(u.displayName.initials)),
                    title: Text(u.displayName),
                    subtitle: Text(u.email),
                    trailing: u.uid == me?.uid
                        ? const Chip(label: Text('Anda'))
                        : SegmentedButton<UserRole>(
                            showSelectedIcon: false,
                            style: const ButtonStyle(visualDensity: VisualDensity.compact),
                            segments: [
                              for (final r in UserRole.values)
                                ButtonSegment(value: r, label: Text(r.label)),
                            ],
                            selected: {u.role},
                            onSelectionChanged: (s) async {
                              final res = await ref
                                  .read(firestoreServiceProvider)
                                  .setRole(u.uid, s.first);
                              if (!context.mounted) return;
                              res.when(
                                success: (_) => context.showSnack(
                                    '${u.displayName} sekarang ${s.first.label}'),
                                failure: (m) => context.showSnack(m, error: true),
                              );
                            },
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: context.colors.primary),
                const SizedBox(height: 8),
                Text(value, style: context.text.headlineSmall),
                Text(label, style: context.text.labelMedium),
              ],
            ),
          ),
        ),
      );
}
