import 'package:http/http.dart' as http;
import 'dart:convert';

/// Claude API Service for AI-powered shift note formatting
/// Handles communication with Anthropic's Claude API
class ClaudeApiService {
  // API configuration
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiVersion = '2023-06-01';
  static const String _model = 'claude-3-5-sonnet-20241022'; // Latest stable version (Oct 2024)
  static const int _maxTokens = 2048;

  // API key - should be loaded from environment variables in production
  // For now, using a placeholder. See setup instructions below.
  final String apiKey;

  ClaudeApiService({required this.apiKey});

  /// Format shift note using Claude API
  /// Takes a formatting prompt and returns the formatted shift note
  Future<String> formatShiftNote(String prompt) async {
    if (apiKey.isEmpty || apiKey == 'YOUR_CLAUDE_API_KEY') {
      throw ClaudeApiException(
        'Claude API key not configured. Please set CLAUDE_API_KEY in your environment.',
        statusCode: 0,
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        if (content.isEmpty) {
          throw ClaudeApiException(
            'Claude API returned empty response',
            statusCode: response.statusCode,
          );
        }
        final text = content[0]['text'] as String;
        return text;
      } else {
        final errorBody = response.body;
        String errorMessage = 'Claude API error: ${response.statusCode}';

        try {
          final errorData = jsonDecode(errorBody) as Map<String, dynamic>;
          if (errorData.containsKey('error')) {
            final error = errorData['error'] as Map<String, dynamic>;
            errorMessage = error['message'] as String? ?? errorMessage;

            // Include error type if available
            if (error.containsKey('type')) {
              final errorType = error['type'] as String;
              errorMessage = '$errorType: $errorMessage';
            }
          }
        } catch (e) {
          // If we can't parse the error, include raw response
          errorMessage = 'Claude API error ${response.statusCode}: $errorBody';
        }

        throw ClaudeApiException(
          errorMessage,
          statusCode: response.statusCode,
          responseBody: errorBody,
        );
      }
    } on ClaudeApiException {
      rethrow;
    } catch (e) {
      throw ClaudeApiException(
        'Failed to format shift note: $e',
        statusCode: 0,
      );
    }
  }

  /// Test the API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 10,
          'messages': [
            {
              'role': 'user',
              'content': 'Hello',
            }
          ],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for Claude API errors
class ClaudeApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  ClaudeApiException(
    this.message, {
    required this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => message;

  /// Check if this is a rate limit error
  bool get isRateLimitError => statusCode == 429;

  /// Check if this is an authentication error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if this is a network error
  bool get isNetworkError => statusCode == 0;
}
