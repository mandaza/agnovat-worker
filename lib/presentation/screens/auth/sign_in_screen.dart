import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../widgets/common/app_logo.dart';

/// Custom sign-in screen using Clerk authentication
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    required this.authState,
  });

  final ClerkAuthState authState;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Step 1: Sign in with Clerk
      await widget.authState.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Step 2: After successful Clerk login, get user info and save clerk_id
      await _syncUserToConvex();

      // ClerkAuthBuilder will rebuild to signed-in state
    } on clerk.AuthError catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Sign in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Sync user from Clerk to Convex and save clerk_id locally
  /// This follows the stateless authentication architecture
  Future<void> _syncUserToConvex() async {
    try {
      // Get Clerk user from ClerkAuth
      final clerkAuth = ClerkAuth.of(context);
      final clerkUser = clerkAuth.user;

      if (clerkUser == null) {
        throw Exception('Clerk user not found after sign-in');
      }

      // Extract user info from Clerk user object
      // Note: Clerk Flutter SDK user properties may vary
      final email = clerkUser.email ?? 'user@agnovat.com';
      final name = clerkUser.name;
      final imageUrl = clerkUser.imageUrl;

      // Save user data to SharedPreferences (for immediate display)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clerk_user_id', clerkUser.id);
      await prefs.setString('clerk_user_name', name);
      await prefs.setString('clerk_user_email', email);
      if (imageUrl != null) {
        await prefs.setString('clerk_user_image_url', imageUrl);
      }

      // Sync user to Convex (create/update user in Convex database)
      final apiService = ref.read(mcpApiServiceProvider);
      
      await apiService.syncUserFromClerk(
        clerkId: clerkUser.id,
        email: email,
        name: name,
        imageUrl: imageUrl,
      );

      // Update last login timestamp
      await apiService.updateLastLogin(clerkUser.id);
    } catch (e) {
      // Log error but don't block login - user can still proceed
      debugPrint('Failed to sync user to Convex: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Brand Section
                _buildLogo(context),
                const SizedBox(height: 48),

                // Welcome Text
                Text(
                  'Welcome to Agnovat',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your NDIS Support Worker Platform',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 🔥 Custom email/password form powered by Clerk
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign In Button
                      ElevatedButton(
                        onPressed: _loading ? null : _handleEmailSignIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _loading ? 'Signing in...' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Info Text
                Text(
                  'By signing in, you agree to our Terms of Service and Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        const AppLogo(
          size: 100,
          showShadow: true,
        ),
        const SizedBox(height: 16),
        Text(
          'Agnovat',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        Text(
          'Support Worker',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
