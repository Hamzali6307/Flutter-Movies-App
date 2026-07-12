import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/service_locator.dart';
import '../services/remote_config_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Artificial delay for splash feel
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final remoteConfig = getIt<RemoteConfigService>();
    if (remoteConfig.isMaintenanceMode) {
      Navigator.pushReplacementNamed(context, Constants.maintenance);
      return;
    }

    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      Navigator.pushReplacementNamed(context, Constants.mainPage);
    } else {
      Navigator.pushReplacementNamed(context, Constants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = getIt<RemoteConfigService>().splashBackgroundUrl;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          if (backgroundUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                backgroundUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              color: themeProvider.isDarkMode 
                  ? Colors.black.withOpacity(0.6) 
                  : Colors.white.withOpacity(0.4),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://w7.pngwing.com/pngs/439/879/png-transparent-movie-projector-logo-clapperboard-computer-icons-movie-logo-television-text-logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "HUB MOVIE'S",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
                LoadingAnimationWidget.beat(
                  color: Colors.redAccent,
                  size: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
