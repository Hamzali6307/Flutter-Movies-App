import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String login = "login_screen";
  static const String movieDetail = "movie_detail";
  static const String playVideo = "play_video";
  static const String myLogs = "my_logs";
  static const String signup = "signup_screen";
  static const String mainPage = "main_page_screen";
  static const String splash = "splash_screen";
  static const String maintenance = "maintenance_screen";

  // Securely fetch from .env file at runtime. 
  // Make sure TMDB_API_KEY and TMDB_BASE_URL are defined in your .env file.
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3/';

  static const String imageUrl = "https://image.tmdb.org/t/p/w500";
}
