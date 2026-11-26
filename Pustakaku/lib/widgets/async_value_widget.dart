import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';

/// Widget generic: merender `AsyncValue<T>` dengan loading/error seragam,
/// sehingga setiap layar cukup menyuplai builder untuk kondisi `data`.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Terjadi kesalahan',
          message: '$e',
          action: onRetry == null
              ? null
              : FilledButton.tonal(onPressed: onRetry, child: const Text('Coba lagi')),
        ),
      );
}
