// 词解析
List<Map<String, dynamic>> parseLrc(String lrc) {
  if (lrc.isEmpty) return [];

  final lrcList = lrc.split('\n');
  final List<Map<String, dynamic>> lrcArr = [];

  final RegExp lyricExp = RegExp(r'^\[(\d{2}):(\d{2})[.:](\d{2,3})\](.*)');

  for (final item in lrcList) {
    final match = lyricExp.firstMatch(item);
    final content = item.replaceAll(RegExp(r'\[\d{2}:\d{2}[.:]\d{2,3}\]'), '').trim();

    if (match != null) {
      final minute = int.parse(match.group(1)!);
      final second = int.parse(match.group(2)!);
      final millisecond = int.parse(match.group(3)!);
      final totalTime = minute * 60 + second + millisecond / 1000.0;

      lrcArr.add({
        "lrc": content,
        "time": totalTime,
      });
    }
  }

  return lrcArr;
}
