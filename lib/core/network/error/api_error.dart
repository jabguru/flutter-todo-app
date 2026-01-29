import 'dart:developer';

import 'package:dio/dio.dart';

class ApiError implements Exception {
  ApiError({
    this.errorCode = '400',
    required this.errorMessage,
    this.errorTitle,
  });

  factory ApiError.fromDioError(Object error) {
    String errorMessage = '';
    String errorCode = '';
    String? errorTitle;

    if (error is DioException) {
      final dioError = error;
      switch (dioError.type) {
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          errorCode = 'REQUEST_CANCELLED';
        case DioExceptionType.connectionTimeout:
          // errorMessage = 'Connection timeout';
          // errorCode = 'CONNECTION_TIMEOUT';
          errorMessage = 'Please check your internet and retry.';
          errorTitle = 'Connection issue';
        case DioExceptionType.connectionError:
          errorMessage = 'Please check your internet and retry.';
          errorTitle = 'Connection issue';
          errorCode = 'NETWORK_ERROR';
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout in connection';
          errorCode = 'RECEIVE_TIMEOUT';
        case DioExceptionType.unknown || DioExceptionType.badResponse:
          if (dioError.response?.statusCode == 401 ||
              dioError.response?.statusCode == 300) {
            errorTitle = 'Session expired';
            errorMessage = 'Please log in again to continue.';
            errorCode = 'SESSION_TIMEOUT';
          } else if (dioError.response?.statusCode == 413) {
            errorMessage = 'The uploaded file is too large.';
            errorCode = 'FILE_TOO_LARGE';
            errorTitle = 'Upload error';
          }
          //  else if (dioError.response!.statusCode! >= 500) {
          //   errorMessage = 'Unable to process the request, Retry!';
          //   errorCode = 'SERVER_FAILURE';
          // }
          else {
            errorMessage = 'Unable to process the request, Retry!';
            errorCode = 'SERVER_FAILURE';

            if (error.response?.data is Map<String, dynamic>) {
              final data = error.response!.data as Map<String, dynamic>;
              if (data.containsKey('errors')) {
                List errors = data['errors'] as List;
                if (errors.isNotEmpty) {
                  List<String> splitString = (errors[0] as String).split(": ");
                  if (splitString.length > 1) {
                    errorTitle = splitString.first;
                  }
                  errorMessage = splitString.last;
                }
              } else if (data.containsKey('message')) {
                errorMessage = data['message'] as String;
              }
            }
          }
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout in connection';
          errorCode = 'SEND_TIMEOUT';
        case DioExceptionType.badCertificate:
          errorMessage = 'Bad certificate';
          errorCode = 'BAD_CERTIFICATE';
      }
    } else {
      errorMessage = _handleException(error);
    }
    log(
      'errorCode: $errorCode, errorTitle: $errorTitle, errorMessage: $errorMessage',
    );

    return ApiError(
      errorCode: errorCode,
      errorMessage: errorMessage,
      errorTitle: errorTitle,
    );
  }

  final String errorCode;
  final String errorMessage;
  final String? errorTitle;

  static String _handleException(dynamic exception) {
    if (exception is String) {
      return 'Unable to process the request, Retry!';
    } else if (exception is ApiError) {
      return exception.errorMessage;
    } else {
      return 'Unable to process the request, Retry!';
    }
  }

  @override
  String toString() =>
      'ApiError(errorCode: $errorCode, errorMessage: $errorMessage, errorTitle: $errorTitle)';
}
