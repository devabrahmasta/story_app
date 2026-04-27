import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/auth_provider.dart';
import '../../presentation/auth/login/login_page.dart';
import '../../presentation/auth/register/register_page.dart';
import '../../presentation/story/add/add_story_page.dart';
import '../../presentation/story/add/camera_screen.dart';
import '../../presentation/story/detail/story_detail_page.dart';
import '../../presentation/story/list/story_list_page.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/stories',
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (!authProvider.isInitialized) {
        return null;
      }

      final isLoggedIn = authProvider.isLoggedIn;
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/stories';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoryListPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddStoryPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StoryDetailPage(storyId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) {
          final cameras = state.extra as List<CameraDescription>? ?? [];
          return CameraScreen(cameras: cameras);
        },
      ),
    ],
  );
}
