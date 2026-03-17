import 'package:go_router/go_router.dart';

import '../presentation/animations/page_transitions.dart';
import '../presentation/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => fadeScaleTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
  ],
);
