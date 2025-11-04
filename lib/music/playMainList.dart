import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/NetImage.dart';

import '../hooks/useStore.dart';
import '../store/index.dart';

// 播放列表
class PlayMainList extends ConsumerStatefulWidget {
  const PlayMainList({super.key});

  @override
  ConsumerState createState() => _PlayMainList();
}

class _PlayMainList extends ConsumerState<PlayMainList> {
  ScrollController _listController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ✅ 等待第一帧绘制完成后再滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = ref.read(musPlayProvider).playList;
      final curIndex = ref.read(musPlayProvider).curIndex;

      if (list.isNotEmpty && curIndex >= 3 && curIndex < list.length) {
        // 每个 item 大概高度（含 Divider、Padding 等），自己可调
        const double itemExtent = 70;
        double offset = curIndex * itemExtent - 3 * itemExtent;

        _listController.jumpTo(
          offset,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final musP = useSelector(ref, musPlayProvider, (s) => s);
    final dispatch = useDispatch(ref, musPlayProvider);
    final list=musP.playList;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 5),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "播放列表 (${list.length})",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded))
              ],
            ),
          ),
        ),
        list.isEmpty
            ? const Center(
                child: Text('暂无播放列表', style: TextStyle(color: Colors.grey)),
              )
            : Expanded(
                child: ListView.separated(
                controller: _listController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 70, endIndent: 15),
                itemBuilder: (context, i) {
                  final m = list[i];
                  final bool isPlaying = i == musP.curIndex&&musP.isPlaying;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      dispatch.playAt(i);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: i==musP.curIndex
                            ? context.line
                                .withOpacity(0.08)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // 封面
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: NetImage(
                                url: m.artUri.toString(),
                                cache: true,
                                width: 50,
                                height: 50,
                                loadingWidget: (ctx, str) => const Padding(
                                  padding: EdgeInsets.all(15),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
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
                                    fontWeight: isPlaying
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isPlaying
                                        ? context.pcr
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
                            const Icon(Icons.equalizer,
                                color: Colors.blueAccent, size: 20),
                          IconButton(onPressed: (){

                          }, icon: Icon(Icons.close,color: context.line,))
                        ],
                      ),
                    ),
                  );
                },
              ))
      ],
    );
  }
}
