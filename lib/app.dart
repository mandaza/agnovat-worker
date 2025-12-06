import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_constants.dart';
import 'presentation/screens/auth/sign_in_screen.dart';
import 'presentation/screens/dashboard/dashboard_router.dart';
import 'presentation/widgets/auth_bootstrapper.dart';

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
            return const AuthBootstrapper(
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
