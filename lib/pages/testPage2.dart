import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  const TestPage2({super.key});

  @override
  State<TestPage2> createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
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
      A(onSkip:onSkip),
      B(),
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
        actions: [
          TextButton(
            onPressed: onSkip,
            child: const Text("跳过", style: TextStyle(color: Colors.blue)),
          ),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: playViews[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class A extends StatefulWidget {
  A({super.key,this.onSkip});
  VoidCallback? onSkip;
  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Column(
          children: [
            TextButton(
              child: Text("Skip"),
              onPressed: widget.onSkip,
            ),
            TextButton(
              child: Text("A 页 count $count"),
              onPressed: () {
                setState(() {
                  count += 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class B extends StatefulWidget {
  const B({super.key});

  @override
  State<B> createState() => _BState();
}

class _BState extends State<B> {
  int count = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade100,
      child: Center(
        child: TextButton(
          child: Text("B 页 count $count"),
          onPressed: () {
            setState(() {
              count += 1;
            });
          },
        ),
      ),
    );
  }
}
