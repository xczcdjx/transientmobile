import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/constants/testData.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/music/tableMusScreen.dart';

import '../hooks/useStore.dart';
import '../service/audioHandlerService.dart';
import '../store/index.dart';
import '../utils/NetImage.dart';
import '../utils/getDevice.dart';
import '../utils/musFun.dart';
import 'lyricScreen.dart';
import 'musScreen.dart';

class MusMainPlay extends ConsumerStatefulWidget {
  /// ✅ 不再要 AnimationController；改成监听可见性
  final ValueListenable<bool> visibleListenable;
  final VoidCallback onClose;

  const MusMainPlay({
    super.key,
    required this.visibleListenable,
    required this.onClose,
  });

  @override
  ConsumerState<MusMainPlay> createState() => _MusMainPlayState();
}

class _MusMainPlayState extends ConsumerState<MusMainPlay> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("1111");
  }
  void onSkip([int index = 1]) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTab = isTabletAll(context);
    final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    // print("list ${musPStore.curSong}");
    List<Map<String,dynamic>> lines=[];
    if (musPStore.curSong != null) {
      if(lyricDataTest[musPStore.curSong?.id]!=null) {
        final lineFc = LrcParser.from(lyricDataTest[musPStore.curSong?.id]!);
        lines=lineFc.lines;
      }
    }
    List<Widget> playViews =  [
      MusScreen(),
      LyricScreen(lines: lines,),
    ];
    // ✅ 用 ValueListenableBuilder 拿到可见状态，驱动显隐动画
    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibleListenable,
      builder: (context, visible, _) {
        // 统一动画参数
        const dur = Duration(milliseconds: 300);
        const curve = Curves.easeOutCubic;

        return AnimatedOpacity(
          duration: dur,
          curve: curve,
          opacity: visible ? 1 : 0,
          // 不可见时禁用点击/手势穿透
          child: IgnorePointer(
            ignoring: !visible,
            child: GestureDetector(
              onTap: widget.onClose, // 点击背景关闭
              child: Stack(
                children: [
                  // 背景模糊图
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                    child: NetImage(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      url: musPStore.curSong?.artUri?.toString() ?? "",
                      fit: BoxFit.cover,
                      cache: true,
                      loadingWidget: (ctx,url)=>Container(color: context.bg,),
                      errorWidget: (ctx,url,error)=>Container(color: context.bg,),
                    ),
                  ),
                  // 渐变遮罩
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          context.bg.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),


                  // ✅ 底部抽屉位移动画（由 visible 控制）
                  AnimatedSlide(
                    duration: dur,
                    curve: curve,
                    offset: visible ? Offset.zero : const Offset(0, 1),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {}, // 阻止事件穿透到背景
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar:
                          AppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            scrolledUnderElevation: 0,          // 关键：滚动下不抬起
                            surfaceTintColor: Colors.transparent, // 关键：取消着色
                            shadowColor: Colors.transparent,      // 保险：不要阴影
                            title: isTab
                                ? Center(child: Text(musPStore.curSong?.title??""))
                                : Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: List.generate(
                                  playViews.length,
                                      (index) {
                                    final isActive =
                                        index == _currentIndex;
                                    return GestureDetector(
                                      onTap: () => onSkip(index),
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 300),
                                        margin:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                        height: 8,
                                        width: isActive ? 20 : 8,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              : Colors.grey.shade400,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            leading: IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(Icons.keyboard_arrow_down),
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  // TODO: 分享逻辑
                                },
                                icon: const Icon(Icons.share),
                              ),
                            ],
                          ),
                          body: isTab
                              ? TableMusScreen(lines: lines,)
                              : Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: playViews.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentIndex = index);
                                  },
                                  itemBuilder: (context, index) =>
                                  playViews[index],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
