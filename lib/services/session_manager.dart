import 'package:flutter/material.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/utils/constants.dart';

class SessionManager {
  final AuthService _authService = getIt<AuthService>();
  final RemoteConfigService _remoteConfigService = getIt<RemoteConfigService>();

  /// Determines the initial screen based on authentication and maintenance state.
  void startSession(BuildContext context) {
    // 1. Check for Maintenance Mode (Remote Config)
    if (_remoteConfigService.isMaintenanceMode) {
      Navigator.pushReplacementNamed(context, Constants.maintenance);
      return;
    }

    // 2. Check if a user is already logged in (Session persistence)
    if (_authService.currentUser != null) {
      // User is logged in, redirect to Home Page
      Navigator.pushReplacementNamed(context, Constants.mainPage);
    } else {
      // No active session, redirect to Login
      Navigator.pushReplacementNamed(context, Constants.login);
    }
  }

  /// Handles user logout and clears the navigation stack.
  Future<void> endSession(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.login,
        (route) => false,
      );
    }
  }
}
