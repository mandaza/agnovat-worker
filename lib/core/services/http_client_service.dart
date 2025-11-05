import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';

/// HTTP client service using Dio
/// Handles all HTTP communication with the MCP backend
class HttpClientService {
  late final Dio _dio;
  final Logger _logger = Logger();

  HttpClientService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.convexUrl, // Using Convex URL as base
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
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.d('Request: ${options.method} ${options.path}');
            _logger.d('Headers: ${options.headers}');
            _logger.d('Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.i('Response: ${response.statusCode} ${response.requestOptions.path}');
            _logger.d('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (ApiConfig.enableLogging && kDebugMode) {
            _logger.e('Error: ${error.requestOptions.path}');
            _logger.e('Message: ${error.message}');
            _logger.e('Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Try to extract error from MCP server response
        if (data is Map<String, dynamic>) {
          final mcpError = data['error'];
          final mcpCode = data['code'];

          if (mcpError != null) {
            return ApiException(
              message: mcpError.toString(),
              code: mcpCode?.toString() ?? 'API_ERROR',
              statusCode: statusCode,
            );
          }
        }

        // Default error messages based on status code
        switch (statusCode) {
          case 400:
            return ApiException(
              message: 'Bad request. Please check your input.',
              code: 'BAD_REQUEST',
              statusCode: statusCode,
            );
          case 401:
            return ApiException(
              message: 'Unauthorized. Please sign in again.',
              code: 'UNAUTHORIZED',
              statusCode: statusCode,
            );
          case 403:
            return ApiException(
              message: 'Access forbidden.',
              code: 'FORBIDDEN',
              statusCode: statusCode,
            );
          case 404:
            return ApiException(
              message: 'Resource not found.',
              code: 'NOT_FOUND',
              statusCode: statusCode,
            );
          case 500:
            return ApiException(
              message: 'Server error. Please try again later.',
              code: 'SERVER_ERROR',
              statusCode: statusCode,
            );
          default:
            return ApiException(
              message: 'An error occurred. Please try again.',
              code: 'UNKNOWN_ERROR',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled.',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          code: 'NO_INTERNET',
        );

      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred.',
          code: 'UNKNOWN',
        );
    }
  }
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

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
