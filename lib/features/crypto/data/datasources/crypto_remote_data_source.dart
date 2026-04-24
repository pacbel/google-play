import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/decrypt_request_model.dart';
import '../models/decrypt_response_model.dart';
import '../models/encrypt_request_model.dart';
import '../models/encrypt_response_model.dart';

abstract class CryptoRemoteDataSource {
  Future<EncryptResponseModel> encrypt(EncryptRequestModel request);
  Future<DecryptResponseModel> decrypt(DecryptRequestModel request);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final Dio _dio;

  const CryptoRemoteDataSourceImpl(this._dio);

  @override
  Future<EncryptResponseModel> encrypt(EncryptRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.encryptEndpoint,
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return EncryptResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        statusCode: response.statusCode ?? 0,
        message: 'Erro no servidor (código HTTP: ${response.statusCode}).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('timeout');
      }
      if (e.response != null) {
        throw ServerException(
          statusCode: e.response!.statusCode ?? 0,
          message: 'Erro no servidor (código HTTP: ${e.response!.statusCode}).',
        );
      }
      throw NetworkException(e.message ?? 'Erro de rede desconhecido.');
    }
  }

  @override
  Future<DecryptResponseModel> decrypt(DecryptRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.decryptEndpoint,
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return DecryptResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        statusCode: response.statusCode ?? 0,
        message: 'Erro no servidor (código HTTP: ${response.statusCode}).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('timeout');
      }
      if (e.response != null) {
        throw ServerException(
          statusCode: e.response!.statusCode ?? 0,
          message: 'Erro no servidor (código HTTP: ${e.response!.statusCode}).',
        );
      }
      throw NetworkException(e.message ?? 'Erro de rede desconhecido.');
    }
  }
}
