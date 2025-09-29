import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hooks/useStore.dart';
import '../store/index.dart';

class CountTest extends ConsumerWidget {
  const CountTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = useSelector(ref, counterProvider, (s) => s);
    final n = useSelector(ref, numProvider, (s) => s);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("CountTest: ${s.count}", style: TextStyle(fontSize: 32)),
          Text("CountNumTest: ${n.count}", style: TextStyle(fontSize: 20)),
        ]);
  }
}
