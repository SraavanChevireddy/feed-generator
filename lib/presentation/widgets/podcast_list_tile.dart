import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import 'package:podcast_api_client/podcast_api_client.dart';
import '../animations/hover_scale_widget.dart';

class PodcastListTile extends StatelessWidget {
  const PodcastListTile({
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
      scale: 1.01,
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildRankBadge(theme),
              const SizedBox(width: 12),
              _buildArtwork(isDark),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(theme, isDark)),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 40 * index),
          duration: 400.ms,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: 40 * index),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildRankBadge(ThemeData theme) {
    return SizedBox(
      width: 28,
      child: Text(
        '${index + 1}',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: index < 3
              ? AppColors.primary
              : theme.colorScheme.onSurfaceVariant.withAlpha(130),
        ),
      ),
    );
  }

  Widget _buildArtwork(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: podcast.artworkUrlSmall != null
            ? CachedNetworkImage(
                imageUrl: podcast.artworkUrlSmall!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withAlpha(30),
                  child: const Icon(Icons.podcasts_rounded, size: 24),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.podcasts_rounded,
                    color: Colors.white, size: 24),
              ),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          podcast.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          podcast.artistName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (podcast.genres.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: podcast.genres.take(2).map((g) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 25 : 12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  g.name,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
