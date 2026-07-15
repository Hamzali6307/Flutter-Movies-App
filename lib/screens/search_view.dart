import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/models/movies.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/service_locator.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_app/screens/movie_detail_screen.dart';

class SearchView extends StatefulWidget {
  final String? initialGenreId;
  final String? initialTitle;
  final String? initialSearchType;

  const SearchView({
    super.key, 
    this.initialGenreId, 
    this.initialTitle, 
    this.initialSearchType,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  
  List<MovieResult> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String? _lastLanguageCode;
  String? _selectedGenreId;

  final List<Map<String, String>> _quickGenres = [
    {'id': '28', 'key': 'action'},
    {'id': '12', 'key': 'adventure'},
    {'id': '16', 'key': 'animated'},
    {'id': '35', 'key': 'comedy'},
    {'id': '80', 'key': 'crime'},
    {'id': '10751', 'key': 'family'},
    {'id': '27', 'key': 'horror'},
    {'id': '9648', 'key': 'mystery'},
    {'id': '10749', 'key': 'romance'},
    {'id': '878', 'key': 'sciFi'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedGenreId = widget.initialGenreId;
    if (widget.initialTitle != null) {
      _searchController.text = widget.initialTitle ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
      _loadMovies();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isFetchingMore && _hasNextPage) {
        _loadMore();
      }
    }
  }

  String _getTmdbLanguage(String code) => code == 'hi' ? 'hi-IN' : 'en-US';

  Future<void> _loadMovies({bool isNextPage = false}) async {
    if (!isNextPage) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _searchResults = [];
        _hasNextPage = true;
      });
    } else {
      setState(() => _isFetchingMore = true);
    }

    Movies? results;
    final api = getIt<ApiService>();
    final query = _searchController.text.trim();
    final tmdbLang = _getTmdbLanguage(Provider.of<LanguageProvider>(context, listen: false).locale.languageCode);

    try {
      if (query.isNotEmpty) {
        results = await api.searchMovies(query, page: _currentPage, language: tmdbLang);
      } else if (_selectedGenreId != null) {
        results = await api.getMovies(page: _currentPage, genreId: _selectedGenreId, language: tmdbLang);
      } else if (widget.initialSearchType == 'top_rated') {
        results = await api.getTopRatedMovies(page: _currentPage, language: tmdbLang);
      } else {
        results = await api.getMovies(page: _currentPage, language: tmdbLang);
      }

      if (mounted) {
        final newItems = results?.results ?? [];
        setState(() {
          if (isNextPage) {
            _searchResults.addAll(newItems);
            _isFetchingMore = false;
          } else {
            _searchResults = newItems;
            _isLoading = false;
          }
          _hasNextPage = newItems.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _isFetchingMore = false; });
    }
  }

  void _loadMore() {
    _currentPage++;
    _loadMovies(isNextPage: true);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty && _selectedGenreId != null) {
        setState(() => _selectedGenreId = null);
      }
      _loadMovies();
    });
  }

  String _getLocalizedGenreName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'action': return l10n.action;
      case 'adventure': return l10n.adventure;
      case 'animated': return l10n.animated;
      case 'comedy': return l10n.comedy;
      case 'crime': return l10n.crime;
      case 'family': return l10n.family;
      case 'horror': return l10n.horror;
      case 'mystery': return l10n.mystery;
      case 'romance': return l10n.romance;
      case 'sciFi': return l10n.sciFi;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchMovies,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickGenres.length,
              itemBuilder: (context, index) {
                final genre = _quickGenres[index];
                final isSelected = _selectedGenreId == genre['id'];
                final genreKey = genre['key'];
                if (genreKey == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _getLocalizedGenreName(genreKey, l10n), 
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      _searchController.clear();
                      setState(() {
                        _selectedGenreId = selected ? genre['id'] : null;
                      });
                      _loadMovies();
                    },
                    selectedColor: Colors.redAccent,
                    backgroundColor: isDark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.05),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingAnimationWidget.beat(
                      color: Colors.redAccent,
                      size: 50,
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noResults,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _searchResults.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _searchResults.length) {
                            return Center(
                              child: LoadingAnimationWidget.beat(
                                color: Colors.redAccent,
                                size: 30,
                              ),
                            );
                          }
                          final movie = _searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              if (movie.id != null) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => MovieDetailScreen(movieId: movie.id!))
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Hero(
                                    tag: 'movie_${movie.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: movie.posterPath != null 
                                            ? "${Constants.imageUrl}${movie.posterPath}" 
                                            : "https://via.placeholder.com/150",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) => Container(color: isDark ? Colors.grey[900] : Colors.grey[200]),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  movie.originalTitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      (movie.voteAverage ?? 0.0).toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
