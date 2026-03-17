import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import 'package:podcast_api_client/podcast_api_client.dart';

class PodcastDetailPanel extends StatelessWidget {
  const PodcastDetailPanel({super.key, required this.podcast});

  final Podcast podcast;

  static Widget buildContent({
    required Podcast podcast,
    required ThemeData theme,
    required bool isDark,
  }) {
    final panel = PodcastDetailPanel(podcast: podcast);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        panel._buildHeader(theme),
        const SizedBox(height: 24),
        panel._buildArtwork(isDark)
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutQuart,
            ),
        const SizedBox(height: 24),
        panel._buildTitle(theme)
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        panel._buildArtist(theme)
            .animate()
            .fadeIn(delay: 150.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 20),
        panel._buildGenres(isDark)
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 24),
        if (podcast.isExplicit)
          panel._buildExplicitBadge(theme)
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 16),
        panel._buildActionButton(theme, isDark)
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.15, end: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          left: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(8),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: buildContent(podcast: podcast, theme: theme, isDark: isDark),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Podcast Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(bool isDark) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: podcast.artworkUrl != null
            ? CachedNetworkImage(
                imageUrl: podcast.artworkUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(Icons.podcasts_rounded,
                      size: 64, color: Colors.white),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.podcasts_rounded,
                    size: 64, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      podcast.name,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }

  Widget _buildArtist(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.person_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            podcast.artistName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: podcast.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            genre.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplicitBadge(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.accent.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explicit_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                'Explicit Content',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (podcast.url != null) {
            launchUrl(Uri.parse(podcast.url!));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text(
          'Open in Apple Podcasts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
