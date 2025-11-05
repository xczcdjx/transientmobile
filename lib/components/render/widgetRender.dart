import 'package:flutter/material.dart';

import '../../models/music/mus_payload_entity.dart';


/// 等价于 TS: renderSingers(payload, cb)
Widget renderSingers(
    MusPayloadEntity? payload, {
      void Function(int id)? onTap,
      TextStyle? enabledStyle,
      TextStyle? disabledStyle,
      bool allowWrap = false, // ✅ 新增参数，默认不换行
    }) {
  final singers = payload?.singers ?? const <CommonShowSingerEntity>[];
  if (singers.isEmpty) {
    return const Text(' - ');
  }

  final defEnabled = enabledStyle ??
      const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      );

  final defDisabled = disabledStyle ??
      TextStyle(
        color: Colors.grey,
      );

  final children = <InlineSpan>[];
  for (var i = 0; i < singers.length; i++) {
    final s = singers[i];
    final clickable = (s.id != null && s.id != 0);

    // ✅ 使用 TextSpan + GestureRecognizer 支持单行模式超出省略
    children.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: clickable ? () => onTap?.call(s.id!) : null,
          child: Text(
            s.name ?? '',
            style: clickable ? defEnabled : defDisabled,
            maxLines: allowWrap ? null : 1,
            overflow: allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (i < singers.length - 1) {
      children.add(const TextSpan(text: '、'));
    }
  }

  // ✅ allowWrap = true → Wrap 多行换行 ✨
  if (allowWrap) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: singers
          .asMap()
          .entries
          .map(
            (e) => GestureDetector(
          onTap: (e.value.id != null && e.value.id != 0)
              ? () => onTap?.call(e.value.id!)
              : null,
          child: Text(
            e.value.name ?? '',
            style: (e.value.id != null && e.value.id != 0)
                ? defEnabled
                : defDisabled,
          ),
        ),
      )
          .toList(),
    );
  }

  // ✅ allowWrap = false → RichText 单行省略
  return RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(children: children),
  );
}
