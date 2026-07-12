import 'package:get_it/get_it.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/session_manager.dart';
import 'package:test_app/services/favourites_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerLazySingleton<ApiService>(() => ApiService());
  }
  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
  }
  if (!getIt.isRegistered<SessionManager>()) {
    getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  }
  if (!getIt.isRegistered<FavouritesService>()) {
    getIt.registerLazySingleton<FavouritesService>(() => FavouritesService());
  }
  if (!getIt.isRegistered<RemoteConfigService>()) {
    getIt.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  }
}
