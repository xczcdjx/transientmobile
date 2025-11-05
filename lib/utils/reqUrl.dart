/// 替换 {size} 占位 或 返回原 url
String? replaceSizeUrl(String? url, {int size = 480}) {
  if (url == null || url.isEmpty) return url;

  if (url.contains('{size}')) {
    return url.replaceAll('{size}', size.toString());
  }
  return url;
}

/// 类似 TS: scaleSizeUrlEmpty
/// 如果包含 /mediaLet | /mediaLg | /mediaMus | /mediaMul/ 直接加 ?size
/// 否则走 replaceSizeUrl
String? scaleSizeUrlEmpty(String? url, {int? size}) {
  if (url == null || url.isEmpty) return url;

  final regex = RegExp(r'/media(?:Let|Lg|Mus|Mul)/');

  if (regex.hasMatch(url)) {
    if (size != null) {
      return '$url?size=${size}x$size';
    }
    return url;
  }

  return replaceSizeUrl(url, size: size ?? 480);
}
