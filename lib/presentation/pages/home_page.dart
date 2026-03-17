import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'package:podcast_api_client/podcast_api_client.dart';
import '../providers/podcast_providers.dart';
import '../widgets/error_display.dart';
import '../widgets/genre_chip_list.dart';
import '../widgets/podcast_card.dart';
import '../widgets/podcast_detail_panel.dart';
import '../widgets/podcast_list_tile.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/stats_header.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const double _desktopBreakpoint = 700;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isBottomSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= HomePage._desktopBreakpoint;
    final selectedPodcast = ref.watch(selectedPodcastProvider);

    ref.listen(selectedPodcastProvider, (prev, next) {
      if (!isDesktop && next != null && !_isBottomSheetOpen) {
        _showDetailBottomSheet(context, next);
      }
    });

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildMainColumn(context)),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutQuart,
                  width: selectedPodcast != null
                      ? AppConstants.sidebarWidth + 40
                      : 0,
                  child: selectedPodcast != null
                      ? PodcastDetailPanel(
                          key: ValueKey(selectedPodcast.id),
                          podcast: selectedPodcast,
                        )
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.1, end: 0, duration: 350.ms)
                      : const SizedBox.shrink(),
                ),
              ],
            )
          : SafeArea(child: _buildMainColumn(context)),
    );
  }

  void _showDetailBottomSheet(BuildContext context, Podcast podcast) {
    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: PodcastDetailPanel.buildContent(
                      podcast: podcast,
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      _isBottomSheetOpen = false;
      ref.read(selectedPodcastProvider.notifier).select(null);
    });
  }

  Widget _buildMainColumn(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildAppBar(context),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SearchBarWidget(),
        ),
        const SizedBox(height: 16),
        const StatsHeader(),
        const SizedBox(height: 12),
        const GenreChipList(),
        const SizedBox(height: 16),
        const Expanded(child: _PodcastContent()),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.podcasts_rounded,
              color: Colors.white,
              size: 22,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Discover top podcasts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}

class _PodcastContent extends ConsumerWidget {
  const _PodcastContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(podcastFeedProvider);
    final viewMode = ref.watch(viewModeProvider);

    return feedAsync.when(
      loading: () => const ShimmerGrid(),
      error: (error, _) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.read(podcastFeedProvider.notifier).refresh(),
      ),
      data: (_) {
        final podcasts = ref.watch(filteredPodcastsProvider);

        if (podcasts.isEmpty) {
          return _buildEmptyState(context);
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: viewMode == ViewMode.grid
              ? _buildGridView(ref, podcasts)
              : _buildListView(ref, podcasts),
        );
      },
    );
  }

  Widget _buildGridView(WidgetRef ref, List podcasts) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return PodcastCard(
          podcast: podcast,
          index: index,
          onTap: () {
            ref.read(selectedPodcastProvider.notifier).select(podcast);
          },
        );
      },
    );
  }

  Widget _buildListView(WidgetRef ref, List podcasts) {
    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: podcasts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return PodcastListTile(
          podcast: podcast,
          index: index,
          onTap: () {
            ref.read(selectedPodcastProvider.notifier).select(podcast);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No podcasts found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
