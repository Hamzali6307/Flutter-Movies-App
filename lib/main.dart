import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/providers/favourites_provider.dart';
import 'package:test_app/providers/theme_provider.dart';
import 'package:test_app/providers/language_provider.dart';
import 'package:test_app/screens/splash_screen.dart';
import 'package:test_app/screens/login_screen.dart';
import 'package:test_app/screens/signup_screen.dart';
import 'package:test_app/screens/main_page.dart';
import 'package:test_app/screens/maintenance_screen.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // 2. Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // 3. Setup Service Locator
  setupServiceLocator();

  // 4. Initialize Remote Config
  try {
    await getIt<RemoteConfigService>().initialize();
  } catch (e) {
    debugPrint("Remote Config initialization failed: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        StreamProvider<User?>.value(
          value: getIt<AuthService>().user,
          initialData: null,
        ),
      ],
      child: const HubMoviesApp(),
    ),
  );
}

class HubMoviesApp extends StatelessWidget {
  const HubMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Hub Movies',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      locale: languageProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: Constants.splash,
      routes: {
        Constants.splash: (context) => const SplashScreen(),
        Constants.login: (context) => const LoginScreen(),
        Constants.signup: (context) => const SignUpScreen(),
        Constants.mainPage: (context) => const MainPage(),
        Constants.maintenance: (context) => const MaintenanceScreen(),
      },
    );
  }
}
