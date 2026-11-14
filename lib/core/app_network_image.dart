import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'app_theme.dart';

/// Kotak abu-abu berkilau yang dipakai sebagai "skeleton" selama
/// gambar atau konten sedang dimuat.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.baseColor = const Color(0xFFE8E4DA),
    this.highlightColor = const Color(0xFFF7F5F0),
  });

  /// Versi gelap, cocok untuk gambar yang ditimpa gradient hitam (banner).
  const ShimmerBox.dark({super.key})
      : baseColor = const Color(0xFF1E4237),
        highlightColor = const Color(0xFF2D5F4F);

  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: const ColoredBox(color: Colors.white),
    );
  }
}

/// Pengganti `CachedNetworkImage` untuk seluruh aplikasi:
/// menampilkan shimmer saat loading, fade-in saat gambar siap,
/// dan ikon cadangan kalau gambar gagal dimuat.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.dark = false,
    this.errorBuilder,
  });

  final String imageUrl;
  final BoxFit fit;

  /// Pakai shimmer gelap (untuk banner).
  final bool dark;

  /// Widget kustom kalau gambar gagal dimuat.
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 350),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) =>
          dark ? const ShimmerBox.dark() : const ShimmerBox(),
      errorWidget: (context, _, __) {
        if (errorBuilder != null) return errorBuilder!(context);
        return const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.muted,
            size: 34,
          ),
        );
      },
    );
  }
}