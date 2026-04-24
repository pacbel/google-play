part of 'crypto_cubit.dart';

sealed class CryptoState {
  const CryptoState();
}

final class CryptoInitial extends CryptoState {
  const CryptoInitial();
}

final class CryptoLoading extends CryptoState {
  const CryptoLoading();
}

final class CryptoSuccess extends CryptoState {
  final String result;
  const CryptoSuccess(this.result);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoSuccess &&
          runtimeType == other.runtimeType &&
          result == other.result;

  @override
  int get hashCode => result.hashCode;
}

final class CryptoFailure extends CryptoState {
  final String message;
  final bool canRetry;

  const CryptoFailure({required this.message, required this.canRetry});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          canRetry == other.canRetry;

  @override
  int get hashCode => Object.hash(message, canRetry);
}
