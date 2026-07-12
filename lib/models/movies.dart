import 'package:json_annotation/json_annotation.dart';

part 'movies.g.dart';

@JsonSerializable()
class Movies {
  final int? page;
  final List<MovieResult>? results;

  Movies({this.page, this.results});

  factory Movies.fromJson(Map<String, dynamic> json) => _$MoviesFromJson(json);
  Map<String, dynamic> toJson() => _$MoviesToJson(this);
}

@JsonSerializable()
class MovieResult {
  final int? id;
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;

  MovieResult({
    this.id,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.voteAverage,
  });

  factory MovieResult.fromJson(Map<String, dynamic> json) => _$MovieResultFromJson(json);
  Map<String, dynamic> toJson() => _$MovieResultToJson(this);
}
