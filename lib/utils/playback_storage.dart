import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../constants/index.dart';
import '../models/store/mus_play_state.dart';
import 'HiveUtil.dart';

/// The queue and cursor are persisted together so an index never outlives its queue.
class PlaybackStorage {
  static (MusPlayState, Duration) read() {
    try {
      final raw =
          HiveUtil.get<Map>('playbackSnapshot', boxName: HiveKeys.music);
      final rows = raw?['items'] ??
          HiveUtil.get<List>(StorageKeys.playList, boxName: HiveKeys.music);
      if (rows is! List) return (MusPlayState(), Duration.zero);
      final items = rows.map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return MediaItem(
          id: map['id'] as String,
          title: map['title'] as String,
          album: map['album'] as String?,
          artist: map['artist'] as String?,
          duration: map['durationMs'] == null
              ? null
              : Duration(milliseconds: (map['durationMs'] as num).toInt()),
          artUri: map['artUri'] == null
              ? null
              : Uri.tryParse(map['artUri'] as String),
          extras: map['extras'] == null
              ? null
              : Map<String, dynamic>.from(map['extras'] as Map),
        );
      }).toList();
      final index = items.isEmpty
          ? 0
          : ((raw?['curIndex'] as int?) ?? 0).clamp(0, items.length - 1);
      final repeat = raw?['repeatMode'];
      final ids = (raw?['randomIdList'] as List?)?.cast<String>() ?? <String>[];
      final validShuffle = items.isNotEmpty &&
          ids.length == items.length &&
          ids.toSet().length == items.length &&
          items.every((item) => ids.contains(item.id));
      var position = Duration(
          milliseconds: ((raw?['positionMs'] as int?) ?? 0).clamp(0, 1 << 53));
      final duration = items.isEmpty ? null : items[index].duration;
      if (duration != null && duration > Duration.zero && position > duration) {
        position = duration;
      }
      return (
        MusPlayState(
          playList: List.unmodifiable(items),
          curIndex: index,
          repeatMode: repeat is int &&
                  repeat >= 0 &&
                  repeat < AudioServiceRepeatMode.values.length
              ? AudioServiceRepeatMode.values[repeat]
              : AudioServiceRepeatMode.none,
          isShuffling: raw?['isShuffling'] == true && validShuffle,
          randomIdList: validShuffle ? List.unmodifiable(ids) : const [],
        ),
        items.isEmpty ? Duration.zero : position
      );
    } catch (error) {
      debugPrint('恢复播放状态失败: $error');
      return (MusPlayState(), Duration.zero);
    }
  }

  static Future<void> save(MusPlayState state, Duration position) async {
    if (!HiveUtil.isBoxOpen(HiveKeys.music)) return;
    try {
      await HiveUtil.set(
          'playbackSnapshot',
          {
            'items': state.playList
                .map((item) => {
                      'id': item.id,
                      'title': item.title,
                      'album': item.album,
                      'artist': item.artist,
                      'durationMs': item.duration?.inMilliseconds,
                      'artUri': item.artUri?.toString(),
                      'extras': item.extras,
                    })
                .toList(),
            'curIndex': state.curIndex,
            'repeatMode': state.repeatMode.index,
            'isShuffling': state.isShuffling,
            'randomIdList': state.randomIdList,
            'positionMs': position.inMilliseconds,
          },
          boxName: HiveKeys.music);
    } catch (error) {
      debugPrint('保存播放状态失败: $error');
    }
  }
}
