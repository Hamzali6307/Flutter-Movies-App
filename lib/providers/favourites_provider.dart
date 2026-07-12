import 'package:flutter/material.dart';
import '../models/movie_detail.dart';
import '../services/favourites_service.dart';
import '../services/service_locator.dart';

class FavouritesProvider extends ChangeNotifier {
  final FavouritesService _service = getIt<FavouritesService>();
  List<MovieDetail> _favourites = [];

  List<MovieDetail> get favourites => _favourites;

  FavouritesProvider() {
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    _favourites = await _service.getFavourites();
    notifyListeners();
  }

  Future<void> toggleFavourite(MovieDetail movie) async {
    await _service.toggleFavourite(movie);
    await _loadFavourites();
  }

  bool isFavourite(int movieId) {
    return _favourites.any((m) => m.id == movieId);
  }
}
