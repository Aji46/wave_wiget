
import 'dart:async';

import 'package:dio/dio.dart';

class WebTokenInterceptor extends Interceptor {
  final Dio dio;
  final List<RequestOptions> _retryQueue = [];
  Completer<void>? _refreshCompleter;

  WebTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path == "refresh") {
      return handler.reject(err);
    }

    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final errorMessage = (err.response?.data is Map<String, dynamic>) ? err.response?.data['errorCode'] : null;

      if (errorMessage == 'INVALID_ACCESS_TOKEN') {
        _retryQueue.add(err.requestOptions);

        if (_refreshCompleter == null) {
          _refreshCompleter = Completer<void>();
          try {
            await _refreshToken();
            _refreshCompleter?.complete();
          } catch (e) {
            _refreshCompleter?.completeError(e);
            _retryQueue.clear();
            _handleLogout();
            return handler.reject(err);
          } finally {
            _refreshCompleter = null;
          }
        } else {
          await _refreshCompleter!.future;
        }

        while (_retryQueue.isNotEmpty) {
          final retryRequest = _retryQueue.removeAt(0);
          try {
            final newResponse = await dio.fetch(retryRequest);
            handler.resolve(newResponse);
          } catch (e) {
            handler.reject(err);
          }
        }
        return;
      }
    }
    handler.next(err);
  }

  Future<void> _refreshToken() async {
    await dio.post("");
  }

  void _handleLogout() {
  }
}
