import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import 'package:podcast_api_client/podcast_api_client.dart';
import '../animations/hover_scale_widget.dart';

class PodcastCard extends StatelessWidget {
  const PodcastCard({
    super.key,
    required this.podcast,
    required this.index,
    required this.onTap,
  });

  final Podcast podcast;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return HoverScaleWidget(
      scale: 1.04,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.black.withAlpha(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _ArtworkSection(
                podcast: podcast,
                isDark: isDark,
              ),
            ),
            Expanded(
              flex: 2,
              child: _InfoSection(
                podcast: podcast,
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 500.ms,
          curve: Curves.easeOutQuart,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 50 * index),
          duration: 500.ms,
          curve: Curves.easeOutQuart,
        );
  }
}

class _ArtworkSection extends StatelessWidget {
  const _ArtworkSection({
    required this.podcast,
    required this.isDark,
  });

  final Podcast podcast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (podcast.artworkUrl != null)
          CachedNetworkImage(
            imageUrl: podcast.artworkUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (context, url, error) => Container(
              color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
              child: Icon(
                Icons.podcasts_rounded,
                size: 48,
                color: AppColors.primary.withAlpha(100),
              ),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(
              Icons.podcasts_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.darkOverlayGradient,
            ),
            child: Container(),
          ),
        ),
        if (podcast.isExplicit)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(160),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${podcast.id.hashCode % 50 + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.podcast,
    required this.theme,
    required this.isDark,
  });

  final Podcast podcast;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            podcast.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            podcast.artistName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (podcast.genres.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 2,
              clipBehavior: Clip.hardEdge,
              children: podcast.genres.take(2).map((genre) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 30 : 15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    genre.name,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
