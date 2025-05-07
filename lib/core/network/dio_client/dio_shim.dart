import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

HttpClientAdapter makeHttpClientAdapter() {
  final adapter = HttpClientAdapter() as BrowserHttpClientAdapter;
  adapter.withCredentials = true;
  return adapter;
}
