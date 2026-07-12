import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/providers/favourites_provider.dart';
import 'package:test_app/providers/theme_provider.dart';
import 'package:test_app/screens/splash_screen.dart';
import 'package:test_app/screens/login_screen.dart';
import 'package:test_app/screens/signup_screen.dart';
import 'package:test_app/screens/main_page.dart';
import 'package:test_app/screens/maintenance_screen.dart';
import 'package:test_app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // 1. Synchronously register all services immediately.
  setupServiceLocator();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        StreamProvider.value(
          value: getIt<AuthService>().user,
          initialData: null,
        ),
      ],
      child: const AppBootstrapper(),
    ),
  );
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  bool _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 2. Initialize Firebase with a timeout.
      await Firebase.initializeApp().timeout(const Duration(seconds: 10));
      
      // 3. Initialize Remote Config once Firebase is ready
      await getIt<RemoteConfigService>().initialize();
      
    } catch (e) {
      debugPrint("Startup Warning (Firebase/Services): $e");
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: LoadingAnimationWidget.beat(
              color: Colors.redAccent,
              size: 50,
            ),
          ),
        ),
      );
    }

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
