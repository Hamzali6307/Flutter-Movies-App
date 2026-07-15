import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/models/movie_detail.dart';
import 'package:test_app/models/movies.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/providers/favourites_provider.dart';
import 'package:test_app/providers/language_provider.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/screens/video_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<MovieDetail?>? _movieDetail;
  Future<Movies?>? _similarMovies;
  Future<Map<String, dynamic>?>? _credits;
  bool _isExpanded = false;
  String? _lastLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    
    if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
      final tmdbLang = _getTmdbLanguage(languageCode);
      final api = getIt<ApiService>();
      
      _movieDetail = api.getMovieDetail(widget.movieId.toString(), language: tmdbLang);
      _similarMovies = api.getSimilarMovies(widget.movieId, language: tmdbLang);
      _credits = api.getMovieCredits(widget.movieId, language: tmdbLang);
    }
  }

  String _getTmdbLanguage(String code) => code == 'hi' ? 'hi-IN' : 'en-US';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<MovieDetail?>(
        future: _movieDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.beat(
                color: Colors.redAccent,
                size: 50,
              ),
            );
          }
          final movie = snapshot.data;
          if (movie == null) {
            return Center(child: Text(l10n.errorLoadingDetails));
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: theme.scaffoldBackgroundColor),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Consumer<FavouritesProvider>(
                              builder: (context, provider, child) {
                                final isFavourite = provider.isFavourite(movie.id ?? 0);
                                return IconButton(
                                  icon: Icon(
                                    isFavourite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavourite ? Colors.red : null,
                                    size: 28,
                                  ),
                                  onPressed: () => provider.toggleFavourite(movie),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Hero(
                          tag: 'movie_${movie.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          movie.title ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          movie.genres?.map((e) => e.name).join(" • ") ?? "",
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.overview ?? "",
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                                child: Text(
                                  _isExpanded ? l10n.readLess : l10n.readMore,
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoItem(context, l10n.rating, movie.voteAverage?.toStringAsFixed(1) ?? "N/A"),
                            _verticalDivider(context),
                            _infoItem(context, l10n.released, _formatDate(movie.releaseDate)),
                            _verticalDivider(context),
                            _infoItem(context, l10n.runtime, "${movie.runtime ?? 'N/A'}m"),
                            _verticalDivider(context),
                            _infoItem(context, l10n.adult, movie.adult == true ? "18+" : "All"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: Text(l10n.watchNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  if (movie.id != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VideoPlayerScreen(movieId: movie.id!)),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildCastSection(context, l10n),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          l10n.similarMovies,
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: FutureBuilder<Movies?>(
                          future: _similarMovies,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.beat(
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                              );
                            }
                            final movies = snapshot.data?.results ?? [];
                            if (movies.isEmpty) {
                              return Center(child: Text(l10n.noSimilarMovies, style: const TextStyle(color: Colors.grey)));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final m = movies[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (m.id != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => MovieDetailScreen(movieId: m.id!.toInt())),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 130,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: "${Constants.imageUrl}${m.posterPath}",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.grey.withValues(alpha: 0.1)),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCastSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            l10n.cast,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _credits,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.redAccent,
                    size: 30,
                  ),
                );
              }
              final cast = snapshot.data?['cast'] as List? ?? [];
              if (cast.isEmpty) {
                return Center(child: Text(l10n.noCastInfo, style: const TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cast.length > 15 ? 15 : cast.length,
                itemBuilder: (context, index) {
                  final actor = cast[index];
                  final profilePath = actor['profile_path'];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          backgroundImage: profilePath != null 
                              ? NetworkImage("${Constants.imageUrl}$profilePath") 
                              : null,
                          child: profilePath == null 
                              ? const Icon(Icons.person, color: Colors.grey) 
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor['name'] ?? "Unknown",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      return date.split('-')[0];
    } catch (e) {
      return date;
    }
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey.withValues(alpha: 0.3));
  }
}
