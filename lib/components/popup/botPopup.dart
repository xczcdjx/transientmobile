import 'package:flutter/material.dart';

class ComBotTest extends StatelessWidget {
  const ComBotTest({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: (){
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 内容超出时可全屏
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('选择播放模式'),
                ListTile(title: Text('顺序播放')),
                ListTile(title: Text('随机播放')),
              ],
            ),
          );
        },
      );
    }, child: Text('botPopup'));
  }
}
