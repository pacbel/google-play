sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure({required this.statusCode, required String message})
      : super(message);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure()
      : super('Sem conexão com a internet. Verifique sua rede e tente novamente.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('A requisição demorou mais de 30 segundos. Tente novamente.');
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
