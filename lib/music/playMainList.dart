import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/play_list_controller.dart';
import '../store/index.dart';
import '../utils/NetImage.dart';

class PlayMainList extends ConsumerStatefulWidget {
  const PlayMainList({super.key});
  @override
  ConsumerState<PlayMainList> createState() => _PlayMainListState();
}

class _PlayMainListState extends ConsumerState<PlayMainList> {
  final _listController = ScrollController();
  static const _rowHeight = 76.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) return;
      final queue = ref.read(musPlayProvider);
      final target = ((queue.curIndex - 2) * _rowHeight)
          .clamp(0.0, _listController.position.maxScrollExtent)
          .toDouble();
      _listController.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(musPlayProvider);
    final actions = ref.read(musPlayProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 14, 14),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('播放列表',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${queue.playList.length} 首歌曲',
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 13)),
              ])),
          IconButton.filledTonal(
              tooltip: '关闭播放列表',
              onPressed: GlobalBottomSheet.hide,
              icon: const Icon(Icons.close_rounded)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
        child: Row(children: [
          Icon(Icons.queue_music_rounded, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
              child: Text('当前列表 (${queue.playList.length})',
                  style: TextStyle(color: colors.onSurfaceVariant))),
          TextButton.icon(
            onPressed: queue.playList.isEmpty
                ? null
                : () async {
                    final confirmed =
                        await GlobalBottomSheet.confirmClear(context);
                    if (confirmed && mounted) await actions.setQueue([]);
                  },
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text('全部清除'),
          ),
        ]),
      ),
      Expanded(
          child: queue.playList.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.queue_music_rounded,
                      size: 48, color: colors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('播放列表为空'),
                  const SizedBox(height: 6),
                  Text('选择喜欢的歌曲，开始收听',
                      style: TextStyle(color: colors.onSurfaceVariant)),
                ]))
              : ListView.builder(
                  controller: _listController,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemExtent: _rowHeight,
                  itemCount: queue.playList.length,
                  itemBuilder: (context, index) {
                    final item = queue.playList[index];
                    final current = index == queue.curIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: current
                            ? colors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => actions.playAt(index),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 4),
                            child: Row(children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: item.artUri == null
                                          ? ColoredBox(
                                              color: colors
                                                  .surfaceContainerHighest,
                                              child: Icon(Icons.music_note,
                                                  color:
                                                      colors.onSurfaceVariant))
                                          : NetImage(
                                              url: item.artUri.toString(),
                                              cache: true,
                                              width: 48,
                                              height: 48))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: current
                                                ? colors.primary
                                                : colors.onSurface,
                                            fontWeight: current
                                                ? FontWeight.w600
                                                : FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(item.artist ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 12)),
                                  ])),
                              if (current)
                                Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                        queue.isPlaying
                                            ? Icons.equalizer_rounded
                                            : Icons.pause_rounded,
                                        color: colors.primary,
                                        size: 20)),
                              IconButton(
                                  tooltip: '移除 ${item.title}',
                                  onPressed: () => actions.removeAt(index),
                                  icon: Icon(Icons.close_rounded,
                                      color: colors.onSurfaceVariant,
                                      size: 20)),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                )),
    ]);
  }
}
