import 'package:flutter/foundation.dart';
import 'package:test_widget/core/network/dio_client/dio_client.dart';
import 'package:test_widget/core/network/interceptors/web_token_interceptor.dart';

import 'dio_shim.dart';
// Remove the original 'package:dio/browser.dart' import

class DioClientImpl extends DioClient {
  @override
  void configureDio() {
    if (kIsWeb) {
      dio.httpClientAdapter = makeHttpClientAdapter();
    }
    dio.interceptors.add(WebTokenInterceptor(dio));
  }
}
