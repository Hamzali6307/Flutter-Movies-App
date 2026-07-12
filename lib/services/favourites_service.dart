import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_detail.dart';

class FavouritesService {
  static const String _key = 'favourite_movies';

  Future<List<MovieDetail>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => MovieDetail.fromJson(e)).toList();
  }

  Future<void> toggleFavourite(MovieDetail movie) async {
    final prefs = await SharedPreferences.getInstance();
    final favourites = await getFavourites();
    
    final index = favourites.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      favourites.removeAt(index);
    } else {
      favourites.add(movie);
    }
    
    await prefs.setString(_key, jsonEncode(favourites.map((e) => e.toJson()).toList()));
  }

  Future<bool> isFavourite(int movieId) async {
    final favourites = await getFavourites();
    return favourites.any((m) => m.id == movieId);
  }
}
