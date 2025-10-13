import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transientmobile/music/lyricScreen.dart';
import 'package:transientmobile/music/musScreen.dart';

class MusMainPlay extends StatefulWidget {
  const MusMainPlay({super.key});

  @override
  State<MusMainPlay> createState() => _MusMainPlayState();
}

class _MusMainPlayState extends State<MusMainPlay> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;

  void onSkip([index=1]) {
    _pageController.animateToPage(index, duration: Duration(microseconds: 200), curve: Curves.easeInOut);
    // 这里写点击跳过的逻辑，比如跳转主页或打印
    /*debugPrint("用户点击了跳过");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("已跳过引导页")),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> playViews =  [
      MusScreen(),
      LyricScreen()
    ];
    return Scaffold(
      appBar: AppBar(
        title: // 顶部指示器
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(playViews.length, (index) {
              final bool isActive = index == _currentIndex;
              return GestureDetector(
                onTap: (){
                  onSkip(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 20 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.keyboard_arrow_down)),
        actions: [
          IconButton(
              onPressed: () {
                // context.pop();
              },
              icon: Icon(Icons.share))
        ],
      ),
      body: Column(
        children: [
          // PageView 主体
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: playViews.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return playViews[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
