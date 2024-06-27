import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    // final url = dotenv.env['API_BASE_URL'];
    final url = 'https://me-achou.vercel.app';
    if (url == null) {
      throw Exception("API_BASE_URL não está definida no arquivo .env");
    }
    return url;
  }

  static String get authEndpoint => '$baseUrl/auth/login';
  static String get googleAuthEndpoint => '$baseUrl/auth/google';
  static String get createUserEndpoint => '$baseUrl/users/register';
  static String get forgotPasswordEndpoint => '$baseUrl/auth/forgot-password';
  static String get resetPasswordEndpoint => '$baseUrl/auth/reset-password';
  static String get getStoresEndpoint => '$baseUrl/stores';
  static String get followStoreEndpoint => '$baseUrl/follow-store/:storeId';
  static String get unfollowStoreEndpoint => '$baseUrl/follow-store/:storeId';
}
