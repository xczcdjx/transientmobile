import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/api/httpSafeExt.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/models/req/recent_up_entity.dart';
import 'package:transientmobile/music/musBotScreen.dart';
import 'package:transientmobile/pages/testPage2.dart';

import '../../components/common/PagedListView.dart';
import '../api/http.dart';
import '../api/url.dart';
import '../components/layout/comOutLet.dart';
import '../components/render/widgetRender.dart';
import '../hooks/useStore.dart';
import '../models/comModels.dart';
import '../store/index.dart';
import '../utils/NetImage.dart';
import '../utils/reqUrl.dart';
import '../utils/screenUtil.dart';

class LastUploadPage extends ConsumerStatefulWidget {
  const LastUploadPage({super.key});

  @override
  ConsumerState<LastUploadPage> createState() => _LastUploadPageState();
}

class _LastUploadPageState extends ConsumerState<LastUploadPage> {
  List<RecentUpEntity> upList = [];
  final api = Http();

  // 模拟后端接口：基于 pageNo/pageSize 返回数据与 total
  Future<PageResult<RecentUpEntity>> _mockFetch(
      int pageNo, int pageSize) async {
    // 这里假装请求网络
    // await Future.delayed(const Duration(milliseconds: 1000));
    final res1 = await api.safeGet<Map<String, dynamic>>(HomeU.recentUp,
        queryParameters: {"pageSize": pageSize, "pageNo": pageNo});
    if (res1.ok) {
      final map = res1.success!.data!; // Response.data
      // ✅ 取出真正分页对象
      final pageMap = map["data"] as Map<String, dynamic>;
      try {
        final res = PageRes.fromJson(
          pageMap,
          (records) => (records as List)
              .map((e) => RecentUpEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        return PageResult(items: res.records, total: res.total);
      } catch (e) {
        print(e);
      }
    } else {
      print('失败: ${res1.f} ${res1.error}');
    }
    /*// 假设总共 87 条
    const total = 87;

    final start = (pageNo - 1) * pageSize;
    final end = (start + pageSize).clamp(0, total);
    final list = List.generate(end - start, (i) => 'Item #${start + i + 1}');
    print(list);*/
    return PageResult(items: [], total: 0);
  }

  @override
  Widget build(BuildContext context) {
    final musP = useSelector(ref, musPlayProvider, (s) => s);
    final dispatch = useDispatch(ref, musPlayProvider);
    final curId = musP.curSong?.id;
    return Scaffold(
      appBar: AppBar(
        leading: BackIcon(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text("最近上传"),
      ),
      body: Column(
        children: [
          Expanded(
              child: PagedListView<RecentUpEntity>(
            fetchPage: _mockFetch,
            pageSize: 15,
            // 默认就是 10
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, item, index) {
              bool isPlaying = item.id.toString() == curId && musP.isPlaying;
              return ListTile(
                onTap: () {
                  dispatch.addMusOne(MediaItem(
                    id: item.id.toString(),
                    title: item.name,
                    album: item.payload?.album,
                    artist: item.payload?.singers
                        ?.map((it) => it.name)
                        .toList()
                        .join('、'),
                    duration: Duration(seconds: item.duration),
                    artUri: Uri.parse(
                      scaleSizeUrlEmpty(item.payload?.imgUrl) ?? "",
                    ),
                    extras: <String, dynamic>{
                      'musUrl': item.musUrl,
                      // 播放用
                      'size': item.size,
                      'albumId': "",
                      'encodeUrl': item.encodeUrl,
                      // 'singers': item.payload?.singers as List<dynamic>? ?? [],
                      'singers': [],
                    },
                  ));
                },
                title: Text(
                  item.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? context.pc : context.fc),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetImage(
                      url: scaleSizeUrlEmpty(item.payload?.imgUrl) ?? "",
                      cache: true,
                      width: 50,
                      height: 50,
                      loadingWidget: (ctx, str) => const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
                subtitle: renderSingers(item.payload, onTap: (id) {
                  print(id);
                }, enabledStyle: TextStyle()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // 关键！避免占满行宽
                  children: [
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.favorite_border)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                  ],
                ),
              );
            },
          ))
        ],
      ),
      bottomNavigationBar: const SafeMusBotScreen());
  }
}

String getSingers(Map<String, dynamic>? payload) {
  if (payload == null) return '-';
  final singers = (payload['singers'] as List<dynamic>? ?? [])
      .map((e) => (e as Map)['name']?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toList()
      .join('、');
  return singers;
}
