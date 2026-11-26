import 'package:flutter/material.dart';

import '../core/extensions.dart';

/// Kotak kerangka berdenyut sebagai penanda konten yang sedang dimuat.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: p.paperDeep,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Kerangka beranda: carousel sampul lalu beberapa kartu.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Skeleton(width: 190, height: 22),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 118, height: 177, radius: 8),
                      SizedBox(height: 10),
                      Skeleton(width: 96),
                    ],
                  ),
                  const SizedBox(width: 14),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Skeleton(width: 150, height: 22),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++) ...[
            const Row(
              children: [
                Skeleton(width: 60, height: 90),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(height: 16),
                      SizedBox(height: 8),
                      Skeleton(width: 120),
                      SizedBox(height: 8),
                      Skeleton(width: 48, height: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      );
}
