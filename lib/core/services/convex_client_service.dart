import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';

/// Convex client service
/// Handles all communication with Convex backend via HTTP API
class ConvexClientService {
  late final Dio _dio;
  final Logger _logger = Logger();

  ConvexClientService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.d('Convex Request: ${options.method} ${options.path}');
            _logger.d('Function: ${options.data?['path']}');
            _logger.d('Args: ${options.data?['args']}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.i('Convex Response: ${response.statusCode}');
            _logger.d('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.e('Convex Error: ${error.requestOptions.path}');
            _logger.e('Message: ${error.message}');
            _logger.e('Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set authentication token (for Clerk integration)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Call a Convex query function
  /// Queries are read-only operations
  Future<T> query<T>(String functionName, {Map<String, dynamic>? args}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.queryUrl,
        data: {
          'path': functionName,
          'args': args ?? {},
        },
      );

      // Convex returns { "value": <result>, "logLines": [...] }
      // Or { "error": {...} } on error
      final data = response.data!;

      if (data.containsKey('error')) {
        throw ConvexException.fromJson(data['error'] as Map<String, dynamic>);
      }

      return data['value'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Call a Convex mutation function
  /// Mutations are write operations
  Future<T> mutation<T>(String functionName, {Map<String, dynamic>? args}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.mutationUrl,
        data: {
          'path': functionName,
          'args': args ?? {},
        },
      );

      // Convex returns { "value": <result>, "logLines": [...] }
      // Or { "error": {...} } on error
      final data = response.data!;

      if (data.containsKey('error')) {
        throw ConvexException.fromJson(data['error'] as Map<String, dynamic>);
      }

      return data['value'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConvexException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Try to extract Convex error
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          return ConvexException.fromJson(data['error'] as Map<String, dynamic>);
        }

        return ConvexException(
          message: 'Server error ($statusCode)',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ConvexException(
          message: 'Request cancelled.',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return ConvexException(
          message: 'No internet connection. Please check your network.',
          code: 'NO_INTERNET',
        );

      default:
        return ConvexException(
          message: error.message ?? 'An unexpected error occurred.',
          code: 'UNKNOWN',
        );
    }
  }
}

/// Convex exception class
/// Matches error format from Convex functions
class ConvexException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ConvexException({
    required this.message,
    required this.code,
    this.statusCode,
    this.data,
  });

  factory ConvexException.fromJson(Map<String, dynamic> json) {
    // Convex error format: { "message": "...", "data": {...} }
    final message = json['message'] as String? ?? 'Unknown error';
    final data = json['data'] as Map<String, dynamic>?;

    // Extract error code from message or data
    String code = 'CONVEX_ERROR';
    if (message.contains('ValidationError')) {
      code = 'VALIDATION_ERROR';
    } else if (message.contains('NotFoundError')) {
      code = 'NOT_FOUND';
    } else if (message.contains('ConflictError')) {
      code = 'CONFLICT';
    } else if (message.contains('AuthorizationError')) {
      code = 'AUTHORIZATION_ERROR';
    }

    return ConvexException(
      message: message,
      code: code,
      data: data,
    );
  }

  @override
  String toString() => message;

  /// Check if error is a validation error
  bool get isValidationError => code == 'VALIDATION_ERROR';

  /// Check if error is not found
  bool get isNotFound => code == 'NOT_FOUND' || statusCode == 404;

  /// Check if error is unauthorized
  bool get isUnauthorized => code == 'UNAUTHORIZED' || statusCode == 401;

  /// Check if error is a conflict
  bool get isConflict => code == 'CONFLICT' || statusCode == 409;

  /// Check if error is authorization error (business rule)
  bool get isAuthorizationError => code == 'AUTHORIZATION_ERROR';

  /// Check if error is a network error
  bool get isNetworkError => code == 'NO_INTERNET' || code == 'TIMEOUT';
}
