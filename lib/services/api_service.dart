import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/movie_detail.dart';
import '../models/movies.dart';
import '../models/trending_movies.dart';
import '../models/video_link.dart';
import '../utils/constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  Future<Movies?> getMovies({required int page, String? genreId, String language = 'en-US'}) async {
    try {
      final response = await _dio.get('discover/movie', queryParameters: {
        'api_key': Constants.apiKey,
        'page': page,
        'language': language,
        if (genreId != null) 'with_genres': genreId,
      });
      return Movies.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getMovies: $e");
      return null;
    }
  }

  Future<Movies?> searchMovies(String query, {int page = 1, String language = 'en-US'}) async {
    try {
      final response = await _dio.get('search/movie', queryParameters: {
        'api_key': Constants.apiKey,
        'query': query,
        'page': page,
        'language': language,
      });
      return Movies.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in searchMovies: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMovieCredits(int movieId, {String language = 'en-US'}) async {
    try {
      final response = await _dio.get('movie/$movieId/credits', queryParameters: {
        'api_key': Constants.apiKey,
        'language': language,
      });
      return response.data;
    } catch (e) {
      debugPrint("Error in getMovieCredits: $e");
      return null;
    }
  }

  Future<Movies?> getSimilarMovies(int movieId, {String language = 'en-US'}) async {
    try {
      final response = await _dio.get('movie/$movieId/similar', queryParameters: {
        'api_key': Constants.apiKey,
        'language': language,
      });
      return Movies.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getSimilarMovies: $e");
      return null;
    }
  }

  Future<Movies?> getTopRatedMovies({required int page, String language = 'en-US'}) async {
    try {
      final response = await _dio.get('movie/top_rated', queryParameters: {
        'api_key': Constants.apiKey,
        'page': page,
        'language': language,
      });
      return Movies.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getTopRatedMovies: $e");
      return null;
    }
  }

  Future<VideoPlayAbleLink?> getVideoPlayAbleLink(int movieId, {String language = 'en-US'}) async {
    try {
      final response = await _dio.get('movie/$movieId/videos', queryParameters: {
        'api_key': Constants.apiKey,
        'language': language,
      });
      return VideoPlayAbleLink.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getVideoPlayAbleLink: $e");
      return null;
    }
  }

  Future<MovieDetail?> getMovieDetail(String movieId, {String language = 'en-US'}) async {
    try {
      final response = await _dio.get('movie/$movieId', queryParameters: {
        'api_key': Constants.apiKey,
        'language': language,
      });
      return MovieDetail.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getMovieDetail: $e");
      return null;
    }
  }

  Future<TrendingMovies?> getTrendingMovies(String timeWindow, {String language = 'en-US'}) async {
    try {
      final response = await _dio.get('trending/movie/$timeWindow', queryParameters: {
        'api_key': Constants.apiKey,
        'language': language,
      });
      return TrendingMovies.fromJson(response.data);
    } catch (e) {
      debugPrint("Error in getTrendingMovies: $e");
      return null;
    }
  }
}
