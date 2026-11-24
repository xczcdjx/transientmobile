import 'package:audio_service/audio_service.dart';
import 'image_request_headers.dart';

/// This audio_service version's copyWith drops artHeaders. Rebuild media items
/// at the publishing boundary so every lyric/duration update retains headers.
MediaItem withArtworkHeaders(MediaItem item) {
  final defaults = imageRequestHeaders(item.artUri?.toString() ?? '');
  if (defaults == null && item.artHeaders == null) return item;
  return MediaItem(
    id: item.id,
    title: item.title,
    album: item.album,
    artist: item.artist,
    genre: item.genre,
    duration: item.duration,
    artUri: item.artUri,
    artHeaders: {...?defaults, ...?item.artHeaders},
    playable: item.playable,
    displayTitle: item.displayTitle,
    displaySubtitle: item.displaySubtitle,
    displayDescription: item.displayDescription,
    rating: item.rating,
    extras: item.extras,
  );
}
