import 'package:json_annotation/json_annotation.dart';

part 'video_link.g.dart';

@JsonSerializable()
class VideoPlayAbleLink {
  final int? id;
  final List<PlayAbleLink>? results;

  VideoPlayAbleLink({this.id, this.results});

  factory VideoPlayAbleLink.fromJson(Map<String, dynamic> json) => _$VideoPlayAbleLinkFromJson(json);
  Map<String, dynamic> toJson() => _$VideoPlayAbleLinkToJson(this);
}

@JsonSerializable()
class PlayAbleLink {
  @JsonKey(name: 'iso_639_1')
  final String? iso6391;
  @JsonKey(name: 'iso_3166_1')
  final String? iso31661;
  final String? name;
  final String? key;
  final String? site;
  final int? size;
  final String? type;
  final bool? official;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  final String? id;

  PlayAbleLink({
    this.iso6391,
    this.iso31661,
    this.name,
    this.key,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
    this.id,
  });

  factory PlayAbleLink.fromJson(Map<String, dynamic> json) => _$PlayAbleLinkFromJson(json);
  Map<String, dynamic> toJson() => _$PlayAbleLinkToJson(this);
}
