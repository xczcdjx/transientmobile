/// Headers required by the public cover CDN, shared by UI and system artwork.
Map<String, String>? imageRequestHeaders(String url) {
  final host = Uri.tryParse(url)?.host.toLowerCase();
  if (host == 'music.126.net' || (host?.endsWith('.music.126.net') ?? false)) {
    return const {'User-Agent': 'Mozilla/5.0'};
  }
  return null;
}
