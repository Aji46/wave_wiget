import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:test_widget/core/constants/constants.dart';
import 'package:test_widget/core/network/interceptors/logging_interceptor.dart';

abstract class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: kConenctionTimeOutSeconds),
      receiveTimeout: const Duration(seconds: kRecieveTimeOutSeconds),
    ));

    configureDio();
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
  }

  void configureDio();
}
