import 'package:json_annotation/json_annotation.dart';
import 'movie_detail.dart';

part 'trending_movies.g.dart';

@JsonSerializable()
class TrendingMovies {
  final int? page;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'total_results')
  final int? totalResults;
  final List<MovieDetail>? results;

  TrendingMovies({
    this.page,
    this.totalPages,
    this.totalResults,
    this.results,
  });

  factory TrendingMovies.fromJson(Map<String, dynamic> json) => _$TrendingMoviesFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingMoviesToJson(this);
}
