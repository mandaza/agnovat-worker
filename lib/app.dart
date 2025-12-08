import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_constants.dart';
import 'presentation/screens/auth/sign_in_screen.dart';
import 'presentation/screens/dashboard/dashboard_router.dart';
import 'presentation/widgets/auth_bootstrapper.dart';
import 'presentation/providers/auth_provider.dart';

/// Root application widget
class AgnovatApp extends StatelessWidget {
  const AgnovatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // No outer Scaffold here - let screens provide their own
      home: ClerkErrorListener(
        child: ClerkAuthBuilder(
          // When user is signed in - route to role-based dashboard
          signedInBuilder: (context, authState) {
            // When Clerk is authenticated, always show the signed-in shell.
            // The shell itself, along with Riverpod state, will handle internal
            // state changes and navigation (like popping back on logout).
            return const _SignedInShell(
              child: DashboardRouter(),
            );
          },
          // When user is signed out - show custom sign-in screen
          signedOutBuilder: (context, authState) {
            // 🔥 Pass authState to custom screen so it can call Clerk
            return SignInScreen(authState: authState);
          },
        ),
      ),
    );
  }
}

/// Shell that listens for auth transitions and resets navigation on logout.
class _SignedInShell extends ConsumerStatefulWidget {
  const _SignedInShell({required this.child});
  final Widget child;

  @override
  ConsumerState<_SignedInShell> createState() => _SignedInShellState();
}

class _SignedInShellState extends ConsumerState<_SignedInShell> {
  @override
  void initState() {
    super.initState();
    // When this shell is first built, it means the user is authenticated.
    // We can now safely trigger the loading of their application-specific profile.
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated && !auth.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBootstrapper(child: widget.child);
  }
}
