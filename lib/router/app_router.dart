import 'package:go_router/go_router.dart';
import '../screens/match_setup_screen.dart';
import '../screens/match_screen.dart';
import '../screens/stats_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MatchSetupScreen(),
      routes: [
        GoRoute(
          path: 'match',
          builder: (context, state) => const MatchScreen(),
          routes: [
            GoRoute(
              path: 'stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
