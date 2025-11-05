// mus_payload_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mus_payload_entity.freezed.dart';
part 'mus_payload_entity.g.dart';

@freezed
class MusPayloadEntity with _$MusPayloadEntity {
  const factory MusPayloadEntity({
    int? id,
    String? album,
    int? albumId,
    List<CommonShowSingerEntity>? singers,
    String? imgUrl,
  }) = _MusPayloadEntity;

  factory MusPayloadEntity.fromJson(Map<String, dynamic> json) =>
      _$MusPayloadEntityFromJson(json);
}

@freezed
class CommonShowSingerEntity with _$CommonShowSingerEntity {
  const factory CommonShowSingerEntity({
    int? id,
    String? name,
  }) = _CommonShowSingerEntity;

  factory CommonShowSingerEntity.fromJson(Map<String, dynamic> json) =>
      _$CommonShowSingerEntityFromJson(json);
}
