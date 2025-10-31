import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/extensions/customColors.dart';

import '../hooks/useStore.dart';
import '../store/index.dart';
class PlayMainList extends ConsumerStatefulWidget{
  const PlayMainList({super.key});
  @override
  ConsumerState createState() =>_PlayMainList();
}
class _PlayMainList extends ConsumerState<PlayMainList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(111);
  }
  @override
  Widget build(BuildContext context) {
    final list = useSelector(ref, musPlayProvider, (s) => s.playList);
    final curIndex = useSelector(ref, musPlayProvider, (s) => s.curIndex);
    final dispatch=useDispatch(ref, musPlayProvider);

    if (list.isEmpty) {
      return const Center(
        child: Text('暂无播放列表', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 70, endIndent: 15),
      itemBuilder: (context, i) {
        final m = list[i];
        final bool isPlaying = i == curIndex;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            dispatch.playAt(i);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isPlaying ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 封面
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    m.artUri?.toString() ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.music_note, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 标题 + 歌手
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                          color: isPlaying
                              ? Theme.of(context).colorScheme.primary
                              : context.fc,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        m.artist ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // 当前播放标识
                if (isPlaying)
                  const Icon(Icons.equalizer, color: Colors.blueAccent, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}