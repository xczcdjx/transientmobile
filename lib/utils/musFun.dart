/// Parses standard LRC timestamps, including centiseconds and repeated tags.
class LrcParser {
  final List<Map<String, dynamic>> _lines;
  LrcParser._(this._lines);

  factory LrcParser.from(String lrc) {
    final timestamps = RegExp(r'\[(\d+):(\d{2})(?:[.:](\d{1,3}))?\]');
    final lines = <Map<String, dynamic>>[];
    for (final raw in lrc.split('\n')) {
      final matches = timestamps.allMatches(raw).toList();
      if (matches.isEmpty) continue;
      final text = raw.substring(matches.last.end).trim();
      for (final match in matches) {
        final fraction = match.group(3) ?? '';
        final milliseconds =
            fraction.isEmpty ? 0 : int.parse(fraction.padRight(3, '0'));
        lines.add({
          'time': int.parse(match.group(1)!) * 60 +
              int.parse(match.group(2)!) +
              milliseconds / 1000,
          'lrc': text,
        });
      }
    }
    lines.sort((a, b) => (a['time'] as num).compareTo(b['time'] as num));
    return LrcParser._(lines);
  }

  String? getByTime(double seconds) {
    var low = 0;
    var high = _lines.length - 1;
    var index = -1;
    while (low <= high) {
      final middle = (low + high) ~/ 2;
      if ((_lines[middle]['time'] as num) <= seconds) {
        index = middle;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return index < 0 ? null : _lines[index]['lrc'] as String;
  }

  List<Map<String, dynamic>> get lines => _lines;
}

// 格式化展示时间
String formatSeconds(double seconds) {
  final d = Duration(seconds: seconds.floor());
  final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$mm:$ss';
}
