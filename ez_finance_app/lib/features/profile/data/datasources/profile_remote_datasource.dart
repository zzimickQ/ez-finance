import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel?> getProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.profile);
      if (response.data != null) {
        return ProfileModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await apiClient.put(
      ApiEndpoints.profile,
      data: profile.toJson(),
    );
    return ProfileModel.fromJson(response.data);
  }
}
