class ServerException implements Exception {
  final int statusCode;
  final String message;

  const ServerException({required this.statusCode, required this.message});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException(message: $message)';
}
