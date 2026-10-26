/// Base class for application exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Thrown when remote server returns an error or invalid response
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.statusCode]);
}

/// Thrown when device has no internet connection or request timed out
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection error']);
}

/// Thrown when translation is not found for the requested word
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Translation not found']);
}

/// Thrown when AnkiDroid is not installed or cannot be opened
class AnkiNotInstalledException extends AppException {
  const AnkiNotInstalledException([super.message = 'Приложение AnkiDroid не найдено на устройстве']);
}

/// Thrown when a general error occurs during Anki export
class AnkiException extends AppException {
  const AnkiException([super.message = 'Не удалось передать карточку в AnkiDroid']);
}
