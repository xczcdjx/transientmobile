// recent_up_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../music/mus_payload_entity.dart';

part 'recent_up_entity.freezed.dart';
part 'recent_up_entity.g.dart';

@freezed
class RecentUpEntity with _$RecentUpEntity {
  const factory RecentUpEntity({
    required int id,
    required DateTime createDate,
    required String name,
    required String musUrl,
    String? imgUrl,
    String? encodeUrl,
    required int duration,
    required int size,
    MusPayloadEntity? payload,
  }) = _RecentUpEntity;

  factory RecentUpEntity.fromJson(Map<String, dynamic> json) =>
      _$RecentUpEntityFromJson(json);
}
