import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/models/movies.dart';
import 'package:test_app/models/trending_movies.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_app/screens/movie_detail_screen.dart';

class HomeView extends StatefulWidget {
  final Function(String? genreId, String? title, String? type)? onSeeAll;

  const HomeView({super.key, this.onSeeAll});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<TrendingMovies?>? _trendingMovies;
  final apiService = getIt<ApiService>();
  String? _lastLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
      _trendingMovies = apiService.getTrendingMovies('day', language: _getTmdbLanguage(languageCode));
    }
  }

  String _getTmdbLanguage(String code) => code == 'hi' ? 'hi-IN' : 'en-US';

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
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Center(child: CircularProgressIndicator());
    
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    final tmdbLang = _getTmdbLanguage(languageCode);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingSection(l10n),
          _buildRow(l10n.featured, l10n.today, (p) => apiService.getTopRatedMovies(page: p, language: tmdbLang), null, 'top_rated', l10n),
          _buildRow(l10n.action, l10n.packed, (p) => apiService.getMovies(page: p, genreId: '28', language: tmdbLang), '28', 'genre', l10n),
          _buildRow(l10n.animated, l10n.world, (p) => apiService.getMovies(page: p, genreId: '16', language: tmdbLang), '16', 'genre', l10n),
          _buildRow(l10n.comedy, l10n.laughter, (p) => apiService.getMovies(page: p, genreId: '35', language: tmdbLang), '35', 'genre', l10n),
          _buildRow(l10n.horror, l10n.night, (p) => apiService.getMovies(page: p, genreId: '27', language: tmdbLang), '27', 'genre', l10n),
          _buildRow(l10n.sciFi, l10n.future, (p) => apiService.getMovies(page: p, genreId: '878', language: tmdbLang), '878', 'genre', l10n),
          _buildRow(l10n.adventure, l10n.quest, (p) => apiService.getMovies(page: p, genreId: '12', language: tmdbLang), '12', 'genre', l10n),
          _buildRow(l10n.mystery, l10n.solving, (p) => apiService.getMovies(page: p, genreId: '9648', language: tmdbLang), '9648', 'genre', l10n),
          _buildRow(l10n.crime, l10n.stories, (p) => apiService.getMovies(page: p, genreId: '80', language: tmdbLang), '80', 'genre', l10n),
          _buildRow(l10n.family, l10n.friendly, (p) => apiService.getMovies(page: p, genreId: '10751', language: tmdbLang), '10751', 'genre', l10n),
          _buildRow(l10n.standard, l10n.movies, (p) => apiService.getMovies(page: p, language: tmdbLang), null, 'discover', l10n),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String subtitle, Future<Movies?> Function(int) fetch, String? genreId, String type, AppLocalizations l10n) {
    return _PaginatedCategoryRow(
      title: title,
      subtitle: subtitle,
      fetchData: fetch,
      onSeeAll: () => widget.onSeeAll?.call(genreId, title, type),
      onMovieTap: _navigateToDetail,
      seeAllText: l10n.seeAll,
    );
  }

  Widget _buildTrendingSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: theme.textTheme.titleLarge?.color
              ),
              children: [
                TextSpan(text: "${l10n.trendingNow.split(' ')[0]} "),
                TextSpan(
                  text: l10n.trendingNow.contains(' ') ? l10n.trendingNow.split(' ').sublist(1).join(' ') : "", 
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)
                ),
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
                              placeholder: (context, url) => Container(color: Colors.grey.withValues(alpha: 0.1)),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
  final String seeAllText;

  const _PaginatedCategoryRow({
    required this.title,
    required this.subtitle,
    required this.fetchData,
    required this.onSeeAll,
    required this.onMovieTap,
    required this.seeAllText,
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
    final theme = Theme.of(context);
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
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: theme.textTheme.titleLarge?.color
                  ),
                  children: [
                    TextSpan(text: "${widget.title} "),
                    TextSpan(text: widget.subtitle, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.onSeeAll, 
                child: Text(widget.seeAllText, style: const TextStyle(color: Colors.grey))
              ),
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
                          placeholder: (context, url) => Container(color: Colors.grey.withValues(alpha: 0.1)),
                          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
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
