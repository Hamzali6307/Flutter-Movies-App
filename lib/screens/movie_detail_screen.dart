import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:test_app/models/movie_detail.dart';
import 'package:test_app/models/movies.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/providers/favourites_provider.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/screens/video_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieDetail?> _movieDetail;
  late Future<Movies?> _similarMovies;
  late Future<Map<String, dynamic>?> _credits;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final api = getIt<ApiService>();
    _movieDetail = api.getMovieDetail(widget.movieId.toString());
    _similarMovies = api.getSimilarMovies(widget.movieId);
    _credits = api.getMovieCredits(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            return const Center(child: Text("Error loading details", style: TextStyle(color: Colors.white)));
          }

          return Stack(
            children: [
              // Background Blurred Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: Colors.black),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              // Content
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
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Consumer<FavouritesProvider>(
                              builder: (context, provider, child) {
                                final isFavourite = provider.isFavourite(movie.id!);
                                return IconButton(
                                  icon: Icon(
                                    isFavourite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavourite ? Colors.red : Colors.white,
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
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          movie.genres?.map((e) => e.name).join(" • ") ?? "",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Overview Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.overview ?? "",
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                                child: Text(
                                  _isExpanded ? "Read Less" : "Read More",
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Info Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoItem("Rating", movie.voteAverage?.toStringAsFixed(1) ?? "N/A"),
                            _verticalDivider(),
                            _infoItem("Released", _formatDate(movie.releaseDate)),
                            _verticalDivider(),
                            _infoItem("Runtime", "${movie.runtime ?? 'N/A'}m"),
                            _verticalDivider(),
                            _infoItem("Adult", movie.adult == true ? "18+" : "All"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Watch Now", style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VideoPlayerScreen(movieId: movie.id!)),
                                  );
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
                      // Cast Section
                      _buildCastSection(),
                      const SizedBox(height: 32),
                      // Similar Movies
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Similar Movies",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                                  color: Colors.white24,
                                  size: 30,
                                ),
                              );
                            }
                            final movies = snapshot.data?.results ?? [];
                            if (movies.isEmpty) {
                              return const Center(child: Text("No similar movies found", style: TextStyle(color: Colors.white24)));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final m = movies[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => MovieDetailScreen(movieId: m.id!.toInt())),
                                    );
                                  },
                                  child: Container(
                                    width: 130,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: "${Constants.imageUrl}${m.posterPath}",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.white10),
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

  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Cast",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                    color: Colors.white24,
                    size: 30,
                  ),
                );
              }
              final cast = snapshot.data?['cast'] as List? ?? [];
              if (cast.isEmpty) {
                return const Center(child: Text("No cast info available", style: TextStyle(color: Colors.white24)));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cast.length > 15 ? 15 : cast.length, // Show top 15
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
                          backgroundColor: Colors.white10,
                          backgroundImage: profilePath != null 
                              ? NetworkImage("${Constants.imageUrl}$profilePath") 
                              : null,
                          child: profilePath == null 
                              ? const Icon(Icons.person, color: Colors.white24) 
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor['name'] ?? "Unknown",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
      return date.split('-')[0]; // Just return the year
    } catch (e) {
      return date;
    }
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }
}
