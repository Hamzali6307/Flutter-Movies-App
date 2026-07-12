import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/remote_config_service.dart';
import 'package:test_app/providers/favourites_provider.dart';
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
  
  runApp(const AppBootstrapper());
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
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: LoadingAnimationWidget.beat(
              color: Colors.redAccent,
              size: 50,
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: getIt<AuthService>().user,
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => FavouritesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Hub Movies',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        initialRoute: Constants.splash,
        routes: {
          Constants.splash: (context) => const SplashScreen(),
          Constants.login: (context) => const LoginScreen(),
          Constants.signup: (context) => const SignUpScreen(),
          Constants.mainPage: (context) => const MainPage(),
          Constants.maintenance: (context) => const MaintenanceScreen(),
        },
      ),
    );
  }
}
