import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';
import '../../features/tenant/presentation/screens/installation_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/client/presentation/screens/client_list_screen.dart';
import '../../features/client/presentation/screens/create_client_screen.dart';

class AppRoutes {
  static const String installation = 'installation';
  static const String login = 'login';
  static const String clients = 'clients';
  static const String createClient = 'create_client';

  static const String installationPath = '/installation';
  static const String loginPath = '/login';
  static const String clientsPath = '/clients';
  static const String createClientPath = '/clients/create';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final localStorage = ref.watch(localStorageProvider);

  return GoRouter(
    initialLocation: AppRoutes.installationPath,
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final tenant = localStorage.getTenant();
      final token = localStorage.getToken();

      final isVerifyingDomain = state.matchedLocation == AppRoutes.installationPath;
      final isLoggingIn = state.matchedLocation == AppRoutes.loginPath;

      // 1. If no tenant verified, force store verification screen
      if (tenant == null || tenant.isEmpty) {
        return isVerifyingDomain ? null : AppRoutes.installationPath;
      }

      // 2. If tenant exists but no auth token, force login screen
      if (token == null || token.isEmpty) {
        return isLoggingIn ? null : AppRoutes.loginPath;
      }

      // 3. If fully authenticated and visiting login or verification screen, redirect to clients
      if (isVerifyingDomain || isLoggingIn) {
        return AppRoutes.clientsPath;
      }

      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          GoRoute(
            name: AppRoutes.installation,
            path: AppRoutes.installationPath,
            builder: (context, state) => const InstallationScreen(),
          ),
          GoRoute(
            name: AppRoutes.login,
            path: AppRoutes.loginPath,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            name: AppRoutes.clients,
            path: AppRoutes.clientsPath,
            builder: (context, state) => const ClientListScreen(),
          ),
        ],
      ),
      // Full screen route overlaying the BottomNavigationBar
      GoRoute(
        name: AppRoutes.createClient,
        path: AppRoutes.createClientPath,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateClientScreen(),
      ),
    ],
  );
});

class MainNavigationScreen extends StatelessWidget {
  final Widget child;
  const MainNavigationScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith(AppRoutes.loginPath)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.clientsPath)) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            context.goNamed(AppRoutes.installation);
          } else if (index == 1) {
            context.goNamed(AppRoutes.login);
          } else if (index == 2) {
            context.goNamed(AppRoutes.clients);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Verify Domain',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Clients',
          ),
        ],
      ),
    );
  }
}
