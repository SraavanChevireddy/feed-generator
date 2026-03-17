import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_api_client/podcast_api_client.dart';

import 'core_providers.dart';

enum ViewMode { grid, list }

// --- Async feed provider ---

final podcastFeedProvider =
    AsyncNotifierProvider<PodcastFeedNotifier, PodcastFeed>(
  PodcastFeedNotifier.new,
);

class PodcastFeedNotifier extends AsyncNotifier<PodcastFeed> {
  @override
  Future<PodcastFeed> build() => _fetchPodcasts();

  Future<PodcastFeed> _fetchPodcasts() async {
    final useCase = ref.read(getTopPodcastsUseCaseProvider);
    final result = await useCase();
    return result.when(
      success: (feed) => feed,
      failure: (error) => throw error,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPodcasts);
  }
}

// --- Simple state providers using Notifier API ---

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final selectedGenreProvider =
    NotifierProvider<SelectedGenreNotifier, String?>(SelectedGenreNotifier.new);

class SelectedGenreNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? genreId) => state = genreId;
}

final viewModeProvider =
    NotifierProvider<ViewModeNotifier, ViewMode>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.grid;

  void setMode(ViewMode mode) => state = mode;
}

final selectedPodcastProvider =
    NotifierProvider<SelectedPodcastNotifier, Podcast?>(
        SelectedPodcastNotifier.new);

class SelectedPodcastNotifier extends Notifier<Podcast?> {
  @override
  Podcast? build() => null;

  void select(Podcast? podcast) => state = podcast;
}

// --- Derived providers ---

final allGenresProvider = Provider<List<Genre>>((ref) {
  final feedAsync = ref.watch(podcastFeedProvider);
  return feedAsync.whenOrNull(
        data: (feed) {
          final filterUseCase = ref.read(filterPodcastsByGenreUseCaseProvider);
          return filterUseCase.extractGenres(feed.podcasts);
        },
      ) ??
      [];
});

final filteredPodcastsProvider = Provider<List<Podcast>>((ref) {
  final feedAsync = ref.watch(podcastFeedProvider);
  final query = ref.watch(searchQueryProvider);
  final genreId = ref.watch(selectedGenreProvider);

  return feedAsync.whenOrNull(
        data: (feed) {
          var podcasts = feed.podcasts;

          final filterUseCase = ref.read(filterPodcastsByGenreUseCaseProvider);
          podcasts = filterUseCase(podcasts: podcasts, genreId: genreId);

          final searchUseCase = ref.read(searchPodcastsUseCaseProvider);
          podcasts = searchUseCase(podcasts: podcasts, query: query);

          return podcasts;
        },
      ) ??
      [];
});
