import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  DioClient._();

  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
        sendTimeout: ApiConstants.timeout,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
      ),
    );
  }
}
