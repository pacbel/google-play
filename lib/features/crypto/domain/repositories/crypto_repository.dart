import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/crypto_result.dart';

abstract class CryptoRepository {
  Future<Either<Failure, CryptoResult>> encrypt(String text);
  Future<Either<Failure, CryptoResult>> decrypt(String bytes);
}
