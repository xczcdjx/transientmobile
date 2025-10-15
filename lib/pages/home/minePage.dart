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
    return TestPage2();
  }
}
