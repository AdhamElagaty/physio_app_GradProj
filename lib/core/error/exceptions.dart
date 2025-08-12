class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class UnauthorizedException extends ServerException {
  UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class NotFoundException extends ServerException {
  NotFoundException({required super.message}) : super(statusCode: 404);
}

class CacheException implements Exception {}

class NetworkException implements Exception {
    @override
  String toString() => 'No internet connection. Please check your network and try again.';
}
