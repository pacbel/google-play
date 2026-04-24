import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/decrypt_use_case.dart';
import '../../domain/usecases/encrypt_use_case.dart';

part 'crypto_state.dart';

enum _OperationType { encrypt, decrypt }

class _LastOperation {
  final _OperationType type;
  final String input;

  const _LastOperation({required this.type, required this.input});
}

class CryptoCubit extends Cubit<CryptoState> {
  final EncryptUseCase _encryptUseCase;
  final DecryptUseCase _decryptUseCase;

  _LastOperation? _lastOperation;

  CryptoCubit({
    required EncryptUseCase encryptUseCase,
    required DecryptUseCase decryptUseCase,
  })  : _encryptUseCase = encryptUseCase,
        _decryptUseCase = decryptUseCase,
        super(const CryptoInitial());

  Future<void> encrypt(String text) async {
    if (text.trim().isEmpty) {
      emit(const CryptoFailure(
        message: 'O campo de texto é obrigatório.',
        canRetry: false,
      ));
      return;
    }
    _lastOperation = _LastOperation(type: _OperationType.encrypt, input: text);
    emit(const CryptoLoading());
    final result = await _encryptUseCase(text);
    result.fold(
      (failure) => emit(CryptoFailure(
        message: _mapFailureMessage(failure),
        canRetry: failure is! UnknownFailure || true,
      )),
      (cryptoResult) => emit(CryptoSuccess(cryptoResult.value)),
    );
  }

  Future<void> decrypt(String bytes) async {
    if (bytes.trim().isEmpty) {
      emit(const CryptoFailure(
        message: 'O campo de bytes é obrigatório.',
        canRetry: false,
      ));
      return;
    }
    _lastOperation =
        _LastOperation(type: _OperationType.decrypt, input: bytes);
    emit(const CryptoLoading());
    final result = await _decryptUseCase(bytes);
    result.fold(
      (failure) => emit(CryptoFailure(
        message: _mapFailureMessage(failure),
        canRetry: true,
      )),
      (cryptoResult) => emit(CryptoSuccess(cryptoResult.value)),
    );
  }

  Future<void> retry() async {
    final last = _lastOperation;
    if (last == null) return;
    if (last.type == _OperationType.encrypt) {
      await encrypt(last.input);
    } else {
      await decrypt(last.input);
    }
  }

  void clear() {
    _lastOperation = null;
    emit(const CryptoInitial());
  }

  String _mapFailureMessage(Failure failure) {
    return switch (failure) {
      NoConnectionFailure() =>
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      TimeoutFailure() =>
        'A requisição demorou mais de 30 segundos. Tente novamente.',
      ServerFailure(:final statusCode) =>
        'Erro no servidor (código HTTP: $statusCode). Tente novamente.',
      UnknownFailure(:final message) => message,
    };
  }
}
