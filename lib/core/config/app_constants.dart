/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Agnovat';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'NDIS Support Worker App';

  // API Configuration (To be configured)
  static const String mcpServerUrl = String.fromEnvironment(
    'MCP_SERVER_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Clerk Configuration (To be configured)
  static const String clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String clerkFrontendApi = String.fromEnvironment(
    'CLERK_FRONTEND_API',
    defaultValue: '',
  );

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int minShiftNoteLength = 50;
  static const int maxShiftNoteLength = 5000;
  static const int ndisNumberLength = 11;

  // Business Rules
  static const int shiftNoteEditWindowHours = 24;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Network Configuration
  static const Duration apiTimeout = Duration(seconds: 10);
  static const int maxRetryAttempts = 3;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
}
