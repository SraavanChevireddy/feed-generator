import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/podcast_providers.dart';
import '../providers/theme_provider.dart';

class StatsHeader extends ConsumerWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feedAsync = ref.watch(podcastFeedProvider);
    final filteredCount = ref.watch(filteredPodcastsProvider).length;
    final viewMode = ref.watch(viewModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Flexible(
            child: feedAsync.whenOrNull(
                  data: (feed) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feed.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 2),
                      Text(
                        '$filteredCount podcasts • ${feed.country ?? "HN"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    ],
                  ),
                ) ??
                const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          _buildViewToggle(ref, viewMode, isDark),
          const SizedBox(width: 8),
          _buildThemeToggle(ref, isDark),
          const SizedBox(width: 8),
          _buildRefreshButton(ref, feedAsync),
        ],
      ),
    );
  }

  Widget _buildViewToggle(WidgetRef ref, ViewMode viewMode, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(10)
            : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: viewMode == ViewMode.grid,
            onTap: () =>
                ref.read(viewModeProvider.notifier).setMode(ViewMode.grid),
          ),
          _ToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: viewMode == ViewMode.list,
            onTap: () =>
                ref.read(viewModeProvider.notifier).setMode(ViewMode.list),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildThemeToggle(WidgetRef ref, bool isDark) {
    return IconButton(
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          size: 20,
        ),
      ),
      tooltip: isDark ? 'Light mode' : 'Dark mode',
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildRefreshButton(WidgetRef ref, AsyncValue feedAsync) {
    return IconButton(
      onPressed: feedAsync.isLoading
          ? null
          : () => ref.read(podcastFeedProvider.notifier).refresh(),
      icon: feedAsync.isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : const Icon(Icons.refresh_rounded, size: 20),
      tooltip: 'Refresh',
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }
}
