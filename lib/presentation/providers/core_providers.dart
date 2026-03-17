import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_api_client/podcast_api_client.dart';

final loggerProvider = Provider<Logger>(
  (ref) => Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
    ),
  ),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(logger: ref.watch(loggerProvider)),
);

final podcastRemoteDataSourceProvider = Provider<PodcastRemoteDataSource>(
  (ref) => PodcastRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  ),
);

final podcastRepositoryProvider = Provider<PodcastRepository>(
  (ref) => PodcastRepositoryImpl(
    remoteDataSource: ref.watch(podcastRemoteDataSourceProvider),
  ),
);

final getTopPodcastsUseCaseProvider = Provider<GetTopPodcastsUseCase>(
  (ref) => GetTopPodcastsUseCase(
    repository: ref.watch(podcastRepositoryProvider),
  ),
);

final searchPodcastsUseCaseProvider = Provider<SearchPodcastsUseCase>(
  (ref) => SearchPodcastsUseCase(),
);

final filterPodcastsByGenreUseCaseProvider =
    Provider<FilterPodcastsByGenreUseCase>(
  (ref) => FilterPodcastsByGenreUseCase(),
);
