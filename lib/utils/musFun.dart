/// 解析 LRC 并按时间取词
class LrcParser {
  final List<Map<String, dynamic>> _lines;

  LrcParser._(this._lines);

  /// 工厂方法：解析 LRC 字符串
  factory LrcParser.from(String lrc) {
    if (lrc.isEmpty) return LrcParser._([]);
    final lrcList = lrc.split('\n');
    final List<Map<String, dynamic>> lrcArr = [];

    final RegExp lyricExp = RegExp(r'^\[(\d{2}):(\d{2})[.:](\d{2,3})\](.*)');

    for (final item in lrcList) {
      final match = lyricExp.firstMatch(item);
      if (match != null) {
        final minute = int.parse(match.group(1)!);
        final second = int.parse(match.group(2)!);
        final millisecond = int.parse(match.group(3)!);
        final totalTime = minute * 60 + second + millisecond / 1000.0;
        final content =
        item.replaceAll(RegExp(r'\[\d{2}:\d{2}[.:]\d{2,3}\]'), '').trim();

        lrcArr.add({
          "lrc": content,
          "time": totalTime,
        });
      }
    }

    // 按时间排序确保一致性
    lrcArr.sort((a, b) => a['time'].compareTo(b['time']));
    return LrcParser._(lrcArr);
  }

  /// 获取指定时间点的歌词
  String? getByTime(double positionSeconds) {
    for (int i = 0; i < _lines.length; i++) {
      final currentTime = _lines[i]["time"]?.toDouble() ?? 0;
      final nextTime = i < _lines.length - 1
          ? _lines[i + 1]["time"]?.toDouble() ?? double.infinity
          : double.infinity;
      if (positionSeconds >= currentTime && positionSeconds < nextTime) {
        return _lines[i]["lrc"];
      }
    }
    return null;
  }

  /// 获取完整的歌词列表
  List<Map<String, dynamic>> get lines => _lines;
}
