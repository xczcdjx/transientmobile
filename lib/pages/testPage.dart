import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/hooks/useAppDispatch.dart';
import 'package:transientmobile/widgets/countTest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hooks/useStore.dart';
import '../store/index.dart';

class TestPage extends ConsumerWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = useSelector(ref, counterProvider, (s) => s.count);
    final nCount = useSelector(ref, numProvider, (s) => s.count);
    final dispatch = useAppDispatch(ref);

    return Scaffold(
        appBar: AppBar(title: Text("test".tr()),),
        body: Center(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text("Count: $count,NumCount: $nCount",
                style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                dispatch.counter.incrementAsync();
                dispatch.num.incrementAsync();
              },
              child: Text("Async +1"),
            ),
            ElevatedButton(
              onPressed: () {
                dispatch.counter.increment();
                dispatch.num.increment();
              },
              child: Text("+1"),
            ),
            CountTest()
          ]),
        ));
  }
}
