import 'package:dio/dio.dart';
import '../models/api_response.dart';

/// Interface for API Service
abstract class IApiService {
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<ApiResponse<T>> post<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<ApiResponse<T>> put<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<ApiResponse<T>> delete<T>(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
}
