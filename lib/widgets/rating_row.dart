import 'package:flutter/material.dart';

import '../core/theme.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int count;

  const RatingRow({super.key, required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          rating == 0 ? 'Нет оценок' : rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        if (count > 0)
          Text(
            '  ·  $count',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
      ],
    );
  }
}
