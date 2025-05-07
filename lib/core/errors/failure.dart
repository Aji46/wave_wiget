
import 'package:test_widget/core/network/models/api_error_type.dart';

class Failure {
  final String message;
  final ApiErrorType reason;

  Failure(this.message, this.reason);
}
