import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  final FlutterSecureStorage secureStorage;

  AppRouter({required this.authBloc, required this.secureStorage});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.welcome,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isLoggedIn = authBloc.state is AuthAuthenticated;
      final isLoggingIn =
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.welcome;

      if (!isLoggedIn && !isLoggingIn) {
        return RouteNames.welcome;
      }

      if (isLoggedIn &&
          (state.matchedLocation == RouteNames.login ||
              state.matchedLocation == RouteNames.welcome)) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
