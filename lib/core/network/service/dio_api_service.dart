import 'package:dio/dio.dart';
import 'package:test_widget/core/network/dio_client/dio_client.dart';
import 'package:test_widget/core/network/models/api_error_type.dart';
import 'package:test_widget/core/network/models/api_response.dart';
import 'package:test_widget/core/network/service/api_service.dart';

/// Concrete implementation using Dio
class DioApiService implements IApiService {
  final DioClient _dioClient;

  DioApiService(this._dioClient);

  Future<ApiResponse<T>> _handleRequest<T>(Future<Response> Function() requestFunction) async {
    try {
      final response = await requestFunction();
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(response.data);
      }
      return _handleErrorResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  ApiResponse<T> _handleErrorResponse<T>(Response response) {
    String errorMessage = "Something went wrong!";

    if (response.data is Map<String, dynamic> && response.data.containsKey('message')) {
      errorMessage = response.data['message'];
    } else if (response.data is String) {
      errorMessage = response.data;
    }

    switch (response.statusCode) {
      case 400:
        return ApiResponse.failure(errorMessage, ApiErrorType.badRequest);
      case 401:
        return ApiResponse.failure(errorMessage, ApiErrorType.unauthorized);
      case 404:
        return ApiResponse.failure(errorMessage, ApiErrorType.notFound);
      case 500:
        return ApiResponse.failure(errorMessage, ApiErrorType.serverError);
      default:
        return ApiResponse.failure(errorMessage, ApiErrorType.unknown);
    }
  }

  ApiResponse<T> _handleDioException<T>(DioException e) {
    if (e.response != null) {
      return _handleErrorResponse(e.response!);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiResponse.failure("Request timed out", ApiErrorType.timeout);
      case DioExceptionType.connectionError:
        return ApiResponse.failure("Connection Error! Unable to connect Server", ApiErrorType.networkError);
      case DioExceptionType.badResponse:
        return ApiResponse.failure("Server returned an invalid response", ApiErrorType.invalidResponse);
      default:
        return ApiResponse.failure("Network error occurred", ApiErrorType.networkError);
    }
  }

  ApiResponse<T> _handleUnexpectedError<T>(dynamic error) {
    return ApiResponse.failure("Unexpected error: ${error.toString()}", ApiErrorType.unknown);
  }

  @override
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return _handleRequest(() => _dioClient.dio.get(endpoint, queryParameters: queryParameters, options: options, cancelToken: cancelToken));
  }

  @override
  Future<ApiResponse<T>> post<T>(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return _handleRequest(
        () => _dioClient.dio.post(endpoint, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));
  }

  @override
  Future<ApiResponse<T>> put<T>(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return _handleRequest(
        () => _dioClient.dio.put(endpoint, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));
  }

  @override
  Future<ApiResponse<T>> delete<T>(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return _handleRequest(
        () => _dioClient.dio.delete(endpoint, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));
  }
}
