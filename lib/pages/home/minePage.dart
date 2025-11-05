import 'package:flutter/material.dart';
import 'package:transientmobile/pages/testPage2.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle_rounded),
            title: Text("My test"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(),
        ],
      ),
    );
  }
}
