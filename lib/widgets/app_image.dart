import 'package:flutter/material.dart';

import '../core/theme.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const AppImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,

      loadingBuilder: (context, child, progress) =>
          progress == null ? child : Container(color: Colors.grey.shade200),

      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.grey,
    ),
  );
}
