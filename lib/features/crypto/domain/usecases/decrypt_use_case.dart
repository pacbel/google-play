import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/crypto_result.dart';
import '../repositories/crypto_repository.dart';

class DecryptUseCase {
  final CryptoRepository _repository;

  const DecryptUseCase(this._repository);

  Future<Either<Failure, CryptoResult>> call(String bytes) {
    return _repository.decrypt(bytes);
  }
}
