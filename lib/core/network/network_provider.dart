import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/core/network/custom_dio_logger.dart';
import 'package:todo_app/core/network/error/api_error.dart';
import 'package:todo_app/core/network/session_timeout_interceptor.dart';

enum RequestMethod { get, post, put, patch, delete, download }

abstract interface class NetworkProvider {
  Future<Response<dynamic>?> call({
    required String path,
    required RequestMethod method,
    dynamic body = const <String, dynamic>{},
    Options? options,
    Map<String, dynamic> queryParams = const {},
    String? savePath,
  });

  void updateToken(String token);
  void updateTokenWithMethod(Future<String?> onToken);
  void clearToken();

  void setSessionTimeoutCallback(VoidCallback callback);

  // void updateTenantId(String tenantId);

  Future<Response<dynamic>?> withFile({
    required String path,
    required String? filePath,
    required String filename,
    required String type,
    required String subType,
    required String jsonData,
  });
}

Future<Map<String, dynamic>> networkHeaders({required String token}) async {
  return {
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    'x-channel': 'MOBILE',
    'accept': '*/*',
    'connection': 'keep-alive',
    'content-type': 'application/json',
  };
}

final class NetworkProviderImpl implements NetworkProvider {
  NetworkProviderImpl({required bool isDebug, VoidCallback? onSessionTimeout})
    : _isDebug = isDebug,
      _onSessionTimeout = onSessionTimeout;

  final bool _isDebug;
  VoidCallback? _onSessionTimeout;

  String? _token;
  // String? _tenantId;

  Future<Dio> _dio({Map<String, dynamic>? headers}) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 50000),
        headers: headers ?? await networkHeaders(token: _token ?? ''),
      ),
    );

    if (_isDebug) {
      // Pretty Dio logger is a Dio interceptor that logs network calls in
      // a pretty, easy to read format.
      dio.interceptors.add(
        DioLogger(requestHeader: true, requestBody: true, responseHeader: true),
      );
    }

    if (_onSessionTimeout != null) {
      dio.interceptors.add(
        SessionTimeoutInterceptor(onSessionTimeout: _onSessionTimeout!),
      );
    }

    return dio;
  }

  @override
  Future<Response<dynamic>?> call({
    required String path,
    required RequestMethod method,
    dynamic body = const <String, dynamic>{},
    Options? options,
    Map<String, dynamic> queryParams = const {},
    String? savePath,
  }) async {
    try {
      final dio = await _dio(headers: options?.headers);

      return switch (method) {
        RequestMethod.get => await dio.get(
          path,
          data: body,
          queryParameters: queryParams,
        ),
        RequestMethod.post => await dio.post(
          path,
          data: body,
          queryParameters: queryParams,
          options: options,
        ),
        RequestMethod.patch => await dio.patch(
          path,
          data: body,
          queryParameters: queryParams,
        ),
        RequestMethod.put => await dio.put(
          path,
          data: body,
          queryParameters: queryParams,
        ),
        RequestMethod.delete => await dio.delete(
          path,
          data: body,
          queryParameters: queryParams,
        ),
        RequestMethod.download => await dio.download(
          path,
          savePath,
          data: body,
          queryParameters: queryParams,
        ),
      };
    } catch (e) {
      return Future.error(ApiError.fromDioError(e));
    }
  }

  @override
  Future<Response<dynamic>?> withFile({
    required String path,
    required String? filePath,
    required String filename,
    required String type,
    required String subType,
    required String jsonData,
  }) async {
    return call(
      path: path,
      method: RequestMethod.post,
      body: FormData.fromMap({
        if (filePath != null)
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filename,
            contentType: DioMediaType(type, subType),
          ),
        'data': jsonData,
      }),
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  @override
  void updateToken(String token) {
    _token = token;
  }

  @override
  void updateTokenWithMethod(Future<String?> onToken) async {
    String? token = await onToken;
    _token = token;
  }

  @override
  void clearToken() {
    _token = null;
  }

  @override
  void setSessionTimeoutCallback(VoidCallback callback) {
    _onSessionTimeout = callback;
  }

  // @override
  // void updateTenantId(String tenantId) {
  //   _tenantId = tenantId;
  // }
}
