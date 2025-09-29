part of '../index.dart';
class NumSlice extends StateNotifier<NumState> {
  NumSlice() : super(const NumState());

  // 同步增加
  void increment() {
    state = state.copyWith(count: state.count + 2);
  }

  // 异步操作示例
  Future<void> incrementAsync() async {
    state = state.copyWith(loading: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        count: state.count + 2,
        loading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}
