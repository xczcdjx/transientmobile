// To parse this JSON data, do
//
//     final bannerEntity = bannerEntityFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'banner_entity.freezed.dart';
part 'banner_entity.g.dart';

BannerEntity bannerEntityFromJson(String str) => BannerEntity.fromJson(json.decode(str));

String bannerEntityToJson(BannerEntity data) => json.encode(data.toJson());

@freezed
class BannerEntity with _$BannerEntity {
  const factory BannerEntity({
    List<BannerItem>? banners,
    String? version,
  }) = _BannerEntity;

  factory BannerEntity.fromJson(Map<String, dynamic> json) => _$BannerEntityFromJson(json);
}

@freezed
class BannerItem with _$BannerItem {
  const factory BannerItem({
    String? id,
    dynamic link,
    int? sort,
    String? type,
    String? title,
    String? imgUrl,
    String? subTitle,
  }) = _BannerItem;

  factory BannerItem.fromJson(Map<String, dynamic> json) => _$BannerItemFromJson(json);
}
