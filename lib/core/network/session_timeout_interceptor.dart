import 'package:dio/dio.dart';

class SessionTimeoutInterceptor extends InterceptorsWrapper {
  SessionTimeoutInterceptor({required this.onSessionTimeout});

  final void Function() onSessionTimeout;

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      onSessionTimeout();
    }
    return super.onError(err, handler);
  }
}
