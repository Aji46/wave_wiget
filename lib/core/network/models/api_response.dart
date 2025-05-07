
import 'package:test_widget/core/network/models/api_error_type.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final ApiErrorType? errorType;

  ApiResponse.success(this.data)
      : success = true,
        errorMessage = null,
        errorType = null;

  ApiResponse.failure(this.errorMessage, this.errorType)
      : success = false,
        data = null;
}
