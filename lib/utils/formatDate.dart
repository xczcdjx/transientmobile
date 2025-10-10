String tranDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
String tranTime(Duration duration) {
  final str = duration.toString();
  final match = RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})')
      .firstMatch(str)
      ?.group(1);
  return match ?? str;
}
