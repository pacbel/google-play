class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://hub-api.sistemavirtual.com.br/api';

  static const String encryptEndpoint = '/Crypto/encrypt';
  static const String decryptEndpoint = '/Crypto/decrypt';

  static const Duration timeout = Duration(seconds: 30);
}
