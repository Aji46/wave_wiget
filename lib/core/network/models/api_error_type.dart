import 'package:flutter/material.dart';

enum ApiErrorType {
  networkError,
  timeout,
  serverError,
  unknown,
  badRequest,
  unauthorized,
  notFound,
  invalidResponse
}

extension ErrorTypeIcon on ApiErrorType {
  IconData get icon {
    switch (this) {
      case ApiErrorType.networkError:
        return Icons.wifi_off;
      case ApiErrorType.serverError:
        return Icons.cloud_off;
      case ApiErrorType.badRequest:
        return Icons.error_outline;
      case ApiErrorType.unknown:
      default:
        return Icons.help_outline;
    }
  }
}