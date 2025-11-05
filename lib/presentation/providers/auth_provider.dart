import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';

/// Auth state - keeping the same structure for compatibility
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Stub auth provider - Clerk SDK handles authentication
/// This is kept for compatibility with existing code
final authProvider = StateProvider<AuthState>((ref) {
  return const AuthState();
});

