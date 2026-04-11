import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  final ProfileBloc profileBloc;
  final FlutterSecureStorage secureStorage;

  AppRouter({
    required this.authBloc,
    required this.profileBloc,
    required this.secureStorage,
  });

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.welcome,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream([
      authBloc.stream,
      profileBloc.stream,
    ]),
    redirect: (context, state) {
      final authState = authBloc.state;
      final profileState = profileBloc.state;

      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthChecking =
          authState is AuthInitial || authState is AuthLoading;

      final isOnAuthPage =
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.welcome;
      final isOnCreateProfile =
          state.matchedLocation == RouteNames.createProfile;

      // Auth status is still being resolved — wait on the welcome page
      if (isAuthChecking) {
        return isOnAuthPage ? null : RouteNames.welcome;
      }

      // Not logged in — must stay on auth pages
      if (!isLoggedIn) {
        return isOnAuthPage ? null : RouteNames.welcome;
      }

      // ── Logged-in from here on ──────────────────────────────────────────

      // User landed on welcome/login while already authenticated
      if (isOnAuthPage) {
        if (profileState is ProfileLoaded) return RouteNames.home;
        if (profileState is ProfileNotFound || profileState is ProfileError) {
          return RouteNames.createProfile;
        }
        // Profile is still loading (ProfileInitial / ProfileLoading) — wait
        return null;
      }

      // User is on the create-profile page
      if (isOnCreateProfile) {
        // Profile already exists — no need to set it up again
        if (profileState is ProfileLoaded) return RouteNames.home;
        return null;
      }

      // Navigating to any other page without a profile — force setup
      if (profileState is ProfileNotFound) {
        return RouteNames.createProfile;
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
        builder: (context, state) =>
            const EditProfilePage(isInitialSetup: false),
      ),
      GoRoute(
        path: RouteNames.createProfile,
        builder: (context, state) =>
            const EditProfilePage(isInitialSetup: true),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams
        .map((stream) => stream.listen((state) => notifyListeners()))
        .toList();
  }

  late final List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
