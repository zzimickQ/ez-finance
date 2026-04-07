import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/database/app_database.dart';
import 'core/api/api_client.dart';
import 'core/network/network_info.dart';
import 'core/sync/sync_manager.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await _initExternal();
  await _initCore();
  _initAuth();
  _initProfile();
}

Future<void> _initExternal() async {
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
}

Future<void> _initCore() async {
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: getIt<Dio>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: getIt<Connectivity>()),
  );

  getIt.registerLazySingleton<SyncManager>(
    () => SyncManager(
      db: getIt<AppDatabase>(),
      apiClient: getIt<ApiClient>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
}

void _initAuth() {
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}

void _initProfile() {
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(db: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
      localDataSource: getIt<ProfileLocalDataSource>(),
      syncManager: getIt<SyncManager>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateProfileUseCase(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      profileRepository: getIt<ProfileRepository>(),
    ),
  );
}
