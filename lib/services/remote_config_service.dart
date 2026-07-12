import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      // 1. Set default values
      // TMDB keys removed from here to keep them secure and separate from Remote Config.
      await _remoteConfig.setDefaults({
        'auth_background_url': 'https://via.placeholder.com/1080x1920',
        'splash_background_url': 'https://via.placeholder.com/1080x1920',
        'is_maintenance_mode': false,
      });

      // 2. Configure settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // 3. Fetch and activate
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config initialization skipped or failed: $e');
    }
  }

  /// Helper to get a string value from remote config
  String getString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (_) {
      return '';
    }
  }

  String get splashBackgroundUrl => getString('splash_background_url');
  String get authBackgroundUrl => getString('auth_background_url');

  bool get isMaintenanceMode {
    try {
      return _remoteConfig.getBool('is_maintenance_mode');
    } catch (_) {
      return false;
    }
  }
}
