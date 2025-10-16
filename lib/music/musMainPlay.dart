import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/music/tableMusScreen.dart';
import '../hooks/useStore.dart';
import '../store/index.dart';
import '../utils/NetImage.dart';
import '../utils/getDevice.dart';
import 'lyricScreen.dart';
import 'musScreen.dart';

class MusMainPlay extends ConsumerStatefulWidget {
  final AnimationController animationController;
  final VoidCallback onClose;

  const MusMainPlay({
    super.key,
    required this.animationController,
    required this.onClose,
  });

  @override
  ConsumerState<MusMainPlay> createState() => _MusMainPlayState();
}

class _MusMainPlayState extends ConsumerState<MusMainPlay> with WidgetsBindingObserver {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;

  final List<Widget> playViews = [
    MusScreen(),
    LyricScreen(),
  ];
  void onSkip([int index = 1]) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    print("11111");
    // 监听返回键
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    // 捕获返回事件并关闭弹窗
    widget.onClose();
    return true; // 阻止默认 pop
  }

  /// ✅ 关闭动画并调用回调
  Future<void> _closeWithAnimation() async {
    await widget.animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isTab = isTabletAll(context);
    final musStore = useSelector(ref, musProvider, (s) => s);
    final animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: widget.onClose, // 点击背景关闭
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: GestureDetector(
            onTap: () {}, // 阻止事件穿透
            child: Align(
                alignment: Alignment.bottomCenter,
                child:
                Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: NetImage(
                          height: MediaQuery.of(context).size.height,
                          url: musStore.curPlayMedia?.artUri?.toString() ?? "",
                          fit: BoxFit.cover,
                          cache: true,
                        ),
                      ),
                      // ✅ 渐变叠加层
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              // Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              context.bg.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          title: isTab
                              ? null
                              : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                              List.generate(playViews.length, (index) {
                                final bool isActive = index == _currentIndex;
                                return GestureDetector(
                                  onTap: () => onSkip(index),
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 8,
                                    width: isActive ? 20 : 8,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }),
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
                            ? TableMusScreen()
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
                    ]
                )
            ),
          ),
        ),
      ),
    );
  }
}
