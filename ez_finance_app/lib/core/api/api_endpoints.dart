class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/';

  static const String login = 'api/auth/login';
  static const String logout = 'api/auth/logout';
  static const String refreshToken = 'api/auth/refresh';
  static const String currentUser = 'api/auth/me';

  static const String profile = 'api/user/profile';

  static String profileById(int id) => 'api/user/profile/$id';
}
