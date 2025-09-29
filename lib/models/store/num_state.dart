import 'package:freezed_annotation/freezed_annotation.dart';

part 'num_state.freezed.dart';

@freezed
class NumState with _$NumState {
  const factory NumState({
    @Default(0) int count,
    @Default(false) bool loading,
    String? error,
  }) = _NumState;
}
