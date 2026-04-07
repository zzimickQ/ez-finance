import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiEndpoints.currentUser);
    return UserModel.fromJson(response.data);
  }
}
