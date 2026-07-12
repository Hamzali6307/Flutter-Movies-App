import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../models/movies.dart';
import '../models/trending_movies.dart';
import '../services/api_service.dart';
import '../services/service_locator.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_detail_screen.dart';

class HomeView extends StatefulWidget {
  final Function(String? genreId, String? title, String? type)? onSeeAll;

  const HomeView({super.key, this.onSeeAll});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<TrendingMovies?> _trendingMovies;
  final apiService = getIt<ApiService>();

  @override
  void initState() {
    super.initState();
    _trendingMovies = apiService.getTrendingMovies('day');
  }

  void _navigateToDetail(int? id) {
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieDetailScreen(movieId: id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingSection(),
          _buildRow("Featured", "Today", (p) => apiService.getTopRatedMovies(page: p), null, 'top_rated'),
          _buildRow("Action", "Packed", (p) => apiService.getMovies(page: p, genreId: '28'), '28', 'genre'),
          _buildRow("Animated", "World", (p) => apiService.getMovies(page: p, genreId: '16'), '16', 'genre'),
          _buildRow("Comedy", "Laughter", (p) => apiService.getMovies(page: p, genreId: '35'), '35', 'genre'),
          _buildRow("Horror", "Night", (p) => apiService.getMovies(page: p, genreId: '27'), '27', 'genre'),
          _buildRow("Sci-Fi", "Future", (p) => apiService.getMovies(page: p, genreId: '878'), '878', 'genre'),
          _buildRow("Adventure", "Quest", (p) => apiService.getMovies(page: p, genreId: '12'), '12', 'genre'),
          _buildRow("Mystery", "Solving", (p) => apiService.getMovies(page: p, genreId: '9648'), '9648', 'genre'),
          _buildRow("Crime", "Stories", (p) => apiService.getMovies(page: p, genreId: '80'), '80', 'genre'),
          _buildRow("Family", "Friendly", (p) => apiService.getMovies(page: p, genreId: '10751'), '10751', 'genre'),
          _buildRow("Standard", "Movies", (p) => apiService.getMovies(page: p), null, 'discover'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String subtitle, Future<Movies?> Function(int) fetch, String? genreId, String type) {
    return _PaginatedCategoryRow(
      title: title,
      subtitle: subtitle,
      fetchData: fetch,
      onSeeAll: () => widget.onSeeAll?.call(genreId, title, type),
      onMovieTap: _navigateToDetail,
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              children: [
                TextSpan(text: "Trending "),
                TextSpan(text: "Now", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 380,
          child: FutureBuilder<TrendingMovies?>(
            future: _trendingMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.redAccent,
                    size: 50,
                  ),
                );
              }
              final movies = snapshot.data?.results ?? [];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () => _navigateToDetail(movie.id),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                              height: 300,
                              width: 200,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[900]),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          Text(
                            movie.genres?.map((e) => e.name).join(" / ") ?? "Movie",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
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
}

class _PaginatedCategoryRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<Movies?> Function(int page) fetchData;
  final VoidCallback onSeeAll;
  final Function(int? id) onMovieTap;

  const _PaginatedCategoryRow({
    required this.title,
    required this.subtitle,
    required this.fetchData,
    required this.onSeeAll,
    required this.onMovieTap,
  });

  @override
  State<_PaginatedCategoryRow> createState() => _PaginatedCategoryRowState();
}

class _PaginatedCategoryRowState extends State<_PaginatedCategoryRow> {
  final ScrollController _scrollController = ScrollController();
  List<MovieResult> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasNextPage) {
        _loadMore();
      }
    }
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    final results = await widget.fetchData(1);
    if (mounted) {
      setState(() {
        _movies = results?.results ?? [];
        _isLoading = false;
        _hasNextPage = _movies.isNotEmpty;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    _currentPage++;
    final results = await widget.fetchData(_currentPage);
    if (mounted) {
      setState(() {
        final newItems = results?.results ?? [];
        _movies.addAll(newItems);
        _isLoading = false;
        _hasNextPage = newItems.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  children: [
                    TextSpan(text: "${widget.title} "),
                    TextSpan(text: widget.subtitle, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              TextButton(onPressed: widget.onSeeAll, child: const Text("See All", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: _movies.isEmpty && _isLoading 
            ? Center(
                child: LoadingAnimationWidget.beat(
                  color: Colors.redAccent,
                  size: 40,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _movies.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _movies.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LoadingAnimationWidget.beat(
                          color: Colors.redAccent,
                          size: 30,
                        ),
                      ),
                    );
                  }
                  final movie = _movies[index];
                  return GestureDetector(
                    onTap: () => widget.onMovieTap(movie.id?.toInt()),
                    child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: "${Constants.imageUrl}${movie.posterPath}",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white24),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
