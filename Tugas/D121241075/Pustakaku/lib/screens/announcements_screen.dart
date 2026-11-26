import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../providers/providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/empty_state.dart';

/// Daftar pengumuman (realtime). Admin dapat membuat pengumuman baru;
/// Cloud Function kemudian mengirim push notification ke semua perangkat
/// yang subscribe topic `pengumuman`.
class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(announcementsProvider);
    final me = ref.watch(appUserProvider).value;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      floatingActionButton: isAdmin && me != null
          ? FloatingActionButton.extended(
              onPressed: () => _compose(context, ref, me),
              icon: const Icon(Icons.add),
              label: const Text('Buat pengumuman'),
            )
          : null,
      body: AsyncValueWidget(
        value: items,
        onRetry: () => ref.invalidate(announcementsProvider),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.campaign_outlined,
                title: 'Belum ada pengumuman',
                message: 'Pengumuman dari admin akan muncul di sini dan dikirim '
                    'sebagai push notification.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final a = list[i];
                  final p = context.palette;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: p.accentSoft, shape: BoxShape.circle),
                            child: Icon(Icons.campaign_rounded, color: p.accent),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: context.text.titleMedium),
                                const SizedBox(height: 6),
                                Text(a.body),
                                const SizedBox(height: 10),
                                Text(
                                  '${a.authorName} · ${a.createdAt?.timeAgo ?? 'mengirim…'}',
                                  style: TextStyle(fontSize: 12, color: p.muted),
                                ),
                              ],
                            ),
                          ),
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: p.muted,
                              tooltip: 'Hapus pengumuman',
                              onPressed: () async {
                                final r = await ref
                                    .read(firestoreServiceProvider)
                                    .deleteAnnouncement(a.id);
                                if (!context.mounted) return;
                                r.when(
                                  success: (_) => context.showSnack('Pengumuman dihapus'),
                                  failure: (m) => context.showSnack(m, error: true),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _compose(BuildContext context, WidgetRef ref, dynamic me) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengumuman baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: body,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Isi pengumuman'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim & notifikasi'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
      if (context.mounted) context.showSnack('Judul dan isi wajib diisi', error: true);
      return;
    }
    final r = await ref.read(firestoreServiceProvider).addAnnouncement(
          title: title.text,
          body: body.text,
          author: me,
        );
    if (!context.mounted) return;
    r.when(
      success: (_) => context.showSnack('Pengumuman terkirim ke semua pengguna'),
      failure: (m) => context.showSnack(m, error: true),
    );
  }
}
