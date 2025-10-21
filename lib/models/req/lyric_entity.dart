// To parse this JSON data, do
//
//     final lyricEntity = lyricEntityFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'lyric_entity.freezed.dart';
part 'lyric_entity.g.dart';

LyricEntity lyricEntityFromJson(String str) => LyricEntity.fromJson(json.decode(str));

String lyricEntityToJson(LyricEntity data) => json.encode(data.toJson());

@freezed
class LyricEntity with _$LyricEntity {
  const factory LyricEntity({
    Lyric? lyric,
  }) = _LyricEntity;

  factory LyricEntity.fromJson(Map<String, dynamic> json) => _$LyricEntityFromJson(json);
}

@freezed
class Lyric with _$Lyric {
  const factory Lyric({
    int? id,
    String? name,
    String? fLyricId,
    String? lyric,
    DateTime? createDate,
    int? musId,
  }) = _Lyric;

  factory Lyric.fromJson(Map<String, dynamic> json) => _$LyricFromJson(json);
}
