import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/services/session_manager.dart';
import 'package:test_app/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  void _startAppFlow() async {
    // Show splash branding for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // Use SessionManager to determine where the user should go
    getIt<SessionManager>().startSession(context);
  }

  @override
  Widget build(BuildContext context) {
    final splashBackground = getIt<RemoteConfigService>().splashBackgroundUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dynamic background from Remote Config
          Positioned.fill(
            child: splashBackground.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: splashBackground,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black),
                    errorWidget: (context, url, error) => Container(color: Colors.black),
                  )
                : Container(color: Colors.black),
          ),
          // Dark overlay for contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Branding Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.movie_filter_rounded, size: 80, color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "HUB MOVIES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),
                LoadingAnimationWidget.beat(
                  color: Colors.redAccent,
                  size: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
