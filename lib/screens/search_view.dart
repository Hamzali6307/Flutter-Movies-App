import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../models/movies.dart';
import '../services/api_service.dart';
import '../services/service_locator.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_detail_screen.dart';

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

  final List<Map<String, String>> _quickGenres = [
    {'id': '28', 'name': 'Action'},
    {'id': '35', 'name': 'Comedy'},
    {'id': '27', 'name': 'Horror'},
    {'id': '878', 'name': 'Sci-Fi'},
    {'id': '16', 'name': 'Animation'},
    {'id': '10749', 'name': 'Romance'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    if (widget.initialGenreId != null || widget.initialSearchType != null) {
      _loadMovies();
      if (widget.initialTitle != null) {
        _searchController.text = widget.initialTitle!;
      }
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

  Future<void> _loadMovies({bool isNextPage = false, String? genreOverride}) async {
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
    final effectiveGenreId = genreOverride ?? widget.initialGenreId;

    try {
      if (query.isNotEmpty) {
        results = await api.searchMovies(query, page: _currentPage);
      } else if (effectiveGenreId != null) {
        results = await api.getMovies(page: _currentPage, genreId: effectiveGenreId);
      } else if (widget.initialSearchType == 'top_rated') {
        results = await api.getTopRatedMovies(page: _currentPage);
      } else {
        results = await api.getMovies(page: _currentPage);
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
          _hasNextPage = newItems.isNotEmpty;
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
      _loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Quick Genre Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickGenres.length,
              itemBuilder: (context, index) {
                final genre = _quickGenres[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(genre['name']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: StadiumBorder(side: BorderSide(color: Colors.white.withOpacity(0.1))),
                    onPressed: () {
                      _searchController.clear();
                      _loadMovies(genreOverride: genre['id']);
                    },
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
                          _searchController.text.isEmpty && widget.initialGenreId == null
                              ? "Type to discover movies!"
                              : "No results found.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
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
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movieId: movie.id!.toInt()))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: movie.posterPath != null ? "${Constants.imageUrl}${movie.posterPath}" : "https://via.placeholder.com/150",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[900]),
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white24),
                              ),
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
