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
  final VoidCallback onClose;

  const MusMainPlay({
    super.key,
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
    // TODO: implement initState
    super.initState();
    print("1111");
  }
  @override
  Widget build(BuildContext context) {
    final isTab = isTabletAll(context);
    final musStore = useSelector(ref, musProvider, (s) => s);


    return Stack(
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
    );
  }
}
