import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'lyricScreen.dart';
import 'musScreen.dart';

class MusMainPlay extends StatefulWidget {
  final AnimationController animationController;
  final VoidCallback onClose;

  const MusMainPlay({
    super.key,
    required this.animationController,
    required this.onClose,
  });

  @override
  State<MusMainPlay> createState() => _MusMainPlayState();
}

class _MusMainPlayState extends State<MusMainPlay> with WidgetsBindingObserver{
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;

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


  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOutCubic,
    );

    final List<Widget> playViews = [
      MusScreen(),
      LyricScreen(),
    ];

    /// ✅ 关闭动画并调用回调
    Future<void> _closeWithAnimation() async {
      await widget.animationController.reverse();
      widget.onClose();
    }

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: widget.onClose, // 点击背景关闭
        child: Material(
          color: Colors.black.withOpacity(0.4),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: GestureDetector(
              onTap: () {}, // 阻止事件穿透
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.88,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    /*borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),*/
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Scaffold(
                    // backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      // backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(playViews.length, (index) {
                            final bool isActive = index == _currentIndex;
                            return GestureDetector(
                              onTap: () => onSkip(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: isActive ? 20 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(context).colorScheme.primary
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
                    body: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: playViews.length,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemBuilder: (context, index) => playViews[index],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
