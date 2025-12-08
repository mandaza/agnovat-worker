import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

/// Ensures local auth cache stays in sync with the current Clerk session.
/// This prevents the app from getting stuck in a loading spinner when the
/// SharedPreferences cache is missing or stale.
class AuthBootstrapper extends ConsumerStatefulWidget {
  const AuthBootstrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthBootstrapper> createState() => _AuthBootstrapperState();
}

class _AuthBootstrapperState extends ConsumerState<AuthBootstrapper> {
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    // Wait for the first frame so context has a mounted tree with ClerkAuth.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLocalCache());
  }

  Future<void> _ensureLocalCache() async {
    if (_synced || !mounted) return;

    // If a logout is in progress, skip syncing entirely to avoid
    // repopulating caches while signing out.
    final authState = ref.read(authProvider);
    if (authState.isLoggingOut) {
      _synced = true;
      return;
    }

    final clerkAuth = ClerkAuth.of(context);
    final clerkUser = clerkAuth.user;
    if (clerkUser == null) return;

    final prefs = await SharedPreferences.getInstance();

    // Normalize user data from Clerk.
    final email = clerkUser.email?.isNotEmpty == true
        ? clerkUser.email!
        : 'user@agnovat.com';
    final name = clerkUser.name.isNotEmpty ? clerkUser.name : 'User';
    final imageUrl = clerkUser.imageUrl;

    // Detect if local cache is missing or stale.
    final needsUpdate =
        prefs.getString('clerk_user_id') != clerkUser.id ||
            prefs.getString('clerk_user_email') != email ||
            prefs.getString('clerk_user_name') != name ||
            prefs.getString('clerk_user_image_url') != (imageUrl ?? '');

    if (needsUpdate) {
      await prefs.setString('clerk_user_id', clerkUser.id);
      await prefs.setString('clerk_user_email', email);
      await prefs.setString('clerk_user_name', name);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await prefs.setString('clerk_user_image_url', imageUrl);
      } else {
        await prefs.remove('clerk_user_image_url');
      }
    }

    // Local data is now up-to-date. The _SignedInShell will trigger profile load.
    _synced = true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

