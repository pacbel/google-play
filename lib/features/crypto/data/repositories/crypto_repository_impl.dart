import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/crypto_result.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_remote_data_source.dart';
import '../models/decrypt_request_model.dart';
import '../models/encrypt_request_model.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource _dataSource;
  final ConnectivityService _connectivityService;

  const CryptoRepositoryImpl({
    required CryptoRemoteDataSource dataSource,
    required ConnectivityService connectivityService,
  })  : _dataSource = dataSource,
        _connectivityService = connectivityService;

  @override
  Future<Either<Failure, CryptoResult>> encrypt(String text) async {
    if (!await _connectivityService.hasConnection()) {
      return const Left(NoConnectionFailure());
    }
    try {
      final response = await _dataSource.encrypt(
        EncryptRequestModel(text: text),
      );
      return Right(CryptoResult(response.bytes));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          statusCode: e.statusCode,
          message: 'Erro no servidor (código HTTP: ${e.statusCode}). Tente novamente.',
        ),
      );
    } on NetworkException catch (e) {
      if (e.message == 'timeout') {
        return const Left(TimeoutFailure());
      }
      return const Left(NoConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure('Ocorreu um erro inesperado. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, CryptoResult>> decrypt(String bytes) async {
    if (!await _connectivityService.hasConnection()) {
      return const Left(NoConnectionFailure());
    }
    try {
      final response = await _dataSource.decrypt(
        DecryptRequestModel(bytes: bytes),
      );
      return Right(CryptoResult(response.text));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          statusCode: e.statusCode,
          message: 'Erro no servidor (código HTTP: ${e.statusCode}). Tente novamente.',
        ),
      );
    } on NetworkException catch (e) {
      if (e.message == 'timeout') {
        return const Left(TimeoutFailure());
      }
      return const Left(NoConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure('Ocorreu um erro inesperado. Tente novamente.'));
    }
  }
}
