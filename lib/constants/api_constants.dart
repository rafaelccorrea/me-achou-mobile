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
  static String get storeDetailsEndpoint => '$baseUrl/stores/details';
  static String get eventsEndpoint => '$baseUrl/events';
  static String get userDetailsEndpoint => '$baseUrl/users';
  static String get userDeleteEndpoint => '$baseUrl/users/delete';
  static String get refreshTokenEndpoint => '$baseUrl/auth/refresh-token';
  static String get getFollowsEndpoint => '$baseUrl/follow-store';
  static String get getFollowersEndpoint => '$baseUrl/follow-store/followers';
  static String get getDetailsSubscriptionEndpoint =>
      '$baseUrl/subscription/details';
  static String get createStoreEndpoint => '$baseUrl/stores';
  static String get uploadProfileImageEndpoint =>
      '$baseUrl/stores/profile-picture/:storeId';
  static String get createSubscriptionEndpoint =>
      '$baseUrl/subscription/create';
  static String get updateUserEndpoint => '$baseUrl/users/update';
}
