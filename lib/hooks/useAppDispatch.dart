import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../store/index.dart';

class AppDispatch {
  final CounterSlice counter;
  final NumSlice num;

  AppDispatch({
    required this.counter,
    required this.num,
  });
}
AppDispatch useAppDispatch(WidgetRef ref) {
  return AppDispatch(
    counter: ref.read(counterProvider.notifier),
    num: ref.read(numProvider.notifier),
  );
}
