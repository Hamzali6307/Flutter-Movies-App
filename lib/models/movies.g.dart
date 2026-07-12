// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movies _$MoviesFromJson(Map<String, dynamic> json) => Movies(
  page: (json['page'] as num?)?.toInt(),
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => MovieResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MoviesToJson(Movies instance) => <String, dynamic>{
  'page': instance.page,
  'results': instance.results,
};

MovieResult _$MovieResultFromJson(Map<String, dynamic> json) => MovieResult(
  id: (json['id'] as num?)?.toInt(),
  originalTitle: json['original_title'] as String?,
  overview: json['overview'] as String?,
  posterPath: json['poster_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MovieResultToJson(MovieResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'original_title': instance.originalTitle,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'vote_average': instance.voteAverage,
    };
