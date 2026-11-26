import 'package:flutter/material.dart';

/// Bintang 1–5. Bila `onChanged` diisi, bintang bisa di-tap (input rating).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 20,
  });

  final double rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = i < rating.round();
          final icon = Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: size,
          );
          return onChanged == null
              ? icon
              : InkResponse(onTap: () => onChanged!(i + 1), radius: size, child: icon);
        }),
      );
}
