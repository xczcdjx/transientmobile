part of '../index.dart';

class CounterSlice extends StateNotifier<CountState> {
  CounterSlice() : super(const CountState());

  void increment() => state = state.copyWith(count: state.count + 1);

  void decrement() => state = state.copyWith(count: state.count - 1);

  // 异步操作，直接修改主要字段
  Future<void> incrementAsync() async {
    await Future.delayed(Duration(seconds: 2)); // 模拟异步
    state = state.copyWith(count: state.count + 1);
  }
}
