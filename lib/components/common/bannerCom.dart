import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/http.dart';
import '../../models/req/banner_entity.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidget();
}

class _BannerWidget extends State<BannerWidget> {
  final http = Http();
  List<BannerItem> banner = [];

  @override
  void initState() {
    super.initState();
    // print("device ${getDevice()}");
    _getBanner();
  }

  _getBanner() async {
    /*const jsonStr = '''
  {
    "banners": [
      {
        "id": "1756981340644",
        "link": null,
        "sort": 1,
        "type": "remote",
        "title": "",
        "imgUrl": "http://transient.online/static/mediaLg/2025/09/04/dh1-1756981760277.png",
        "subTitle": "寥廓东湖..."
      },
    ],
    "version": "1.1.0"
  }
  ''';
    final entity=bannerEntityFromJson(jsonStr);*/
    final res1 = await http.get<Map<String, dynamic>>("/home/banner",
        queryParameters: {"page": 1});
    // final list=bannerEntityFromJson(res1.data?["data"]);
    final rr = BannerEntity.fromJson(res1.data?["data"]);
    setState(() {
      banner = rr.banners ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        banner.isEmpty
            ? const Center(child: CircularProgressIndicator()) // 加载中
            : SizedBox(
          height: 200, // 固定高度
          child: PageView.builder(
            itemCount: banner.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final item = banner[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 图片
                      if (item.imgUrl != null)
                        Image.network(
                          item.imgUrl!,
                          fit: BoxFit.cover,
                        ),
                      // 底部文字遮罩
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subTitle ?? "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}