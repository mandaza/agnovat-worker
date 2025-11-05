/// Clerk authentication configuration
/// Using Frontend API for custom UI with OAuth support
class ClerkConfig {
  ClerkConfig._();

  // Clerk Publishable Key (Test Environment)
  static const String publishableKey = 'pk_test_dmVyaWZpZWQtc3RpbmdyYXktODEuY2xlcmsuYWNjb3VudHMuZGV2JA';

  // Clerk Frontend API URL
  static const String frontendApi = 'https://verified-stingray-81.accounts.dev';

  // OAuth Redirect Configuration
  static const String redirectScheme = 'agnovat';
  static const String redirectUri = '$redirectScheme://oauth'; // Match Clerk Dashboard

  // Clerk Frontend API Endpoints (for custom UI)
  static String get clientUrl => '$frontendApi/v1/client';
  static String get signInsUrl => '$frontendApi/v1/client/sign_ins';
  static String get signUpsUrl => '$frontendApi/v1/client/sign_ups';

  // Sign in attempt endpoint (dynamic with signInId)
  static String signInAttemptUrl(String signInId) =>
      '$frontendApi/v1/client/sign_ins/$signInId/attempt_first_factor';

  // Sign up attempt endpoint (dynamic with signUpId)
  static String signUpAttemptUrl(String signUpId) =>
      '$frontendApi/v1/client/sign_ups/$signUpId/attempt_verification';

  // External account endpoint for OAuth callback
  static String externalAccountUrl(String signInId) =>
      '$frontendApi/v1/client/sign_ins/$signInId/authenticator';

  // Token Storage Keys
  static const String sessionTokenKey = 'clerk_session_token';
  static const String userIdKey = 'clerk_user_id';
  static const String sessionIdKey = 'clerk_session_id';
  static const String pendingSignInIdKey = 'clerk_pending_sign_in_id';

  // OAuth Providers
  static const String googleProvider = 'oauth_google';
  static const String appleProvider = 'oauth_apple';
}
