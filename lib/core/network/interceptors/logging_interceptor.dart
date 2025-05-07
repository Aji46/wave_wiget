import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  String _formatHeaders(Map<String, dynamic> headers) {
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('''
📡 REQUEST
${options.method} ${options.uri}
Headers:
${_formatHeaders(options.headers)}
${options.data != null ? '\nBody:\n${options.data}' : ''}
    ''');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i('''
✅ RESPONSE
${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}
Headers:
${_formatHeaders(response.headers.map)}
Body:
${response.data}
    ''');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('''
❌ ERROR
Type: ${err.type}
Message: ${err.message}
${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}
${err.response != null ? '\nResponse data:\n${err.response?.data}' : ''}
    ''');
    super.onError(err, handler);
  }
}
