import 'package:go_router/go_router.dart';

import '../features/auth/auth_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/groups/group_detail_screen.dart';
import '../features/groups/groups_screen.dart';
import '../features/rehearsals/rehearsal_detail_screen.dart';
import '../features/scores/score_viewer_screen.dart';

GoRouter buildRouter(AuthService auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/', builder: (c, s) => const GroupsScreen()),
      GoRoute(
        path: '/groups/:id',
        builder: (c, s) => GroupDetailScreen(groupId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/rehearsals/:id',
        builder: (c, s) =>
            RehearsalDetailScreen(rehearsalId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/viewer',
        builder: (c, s) {
          final extra = s.extra as Map<String, String>? ?? {};
          return ScoreViewerScreen(
            title: extra['title'] ?? 'Partitura',
            fileUrl: extra['url'] ?? '',
            format: extra['format'] ?? 'musicxml',
          );
        },
      ),
    ],
  );
}
