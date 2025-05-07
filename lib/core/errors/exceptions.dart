abstract class AppException implements Exception {
  final String message;

  AppException(this.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache Error']);
}

class FormEndedException extends AppException {
  FormEndedException([super.message = 'Form Ended']);
}
