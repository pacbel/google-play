import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/crypto_result.dart';
import '../repositories/crypto_repository.dart';

class EncryptUseCase {
  final CryptoRepository _repository;

  const EncryptUseCase(this._repository);

  Future<Either<Failure, CryptoResult>> call(String text) {
    return _repository.encrypt(text);
  }
}
