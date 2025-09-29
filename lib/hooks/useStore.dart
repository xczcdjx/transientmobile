import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Redux 风格的 useSelector
T useSelector<T, State>(
    WidgetRef ref,
    StateNotifierProvider<StateNotifier<State>, State> provider,
    T Function(State) selector,
    ) {
  final state = ref.watch(provider);
  return selector(state);
}

/// Redux 风格的 useDispatch
Notifier useDispatch<Notifier extends StateNotifier<State>, State>(
    WidgetRef ref,
    StateNotifierProvider<Notifier, State> provider,
    ) {
  return ref.read(provider.notifier);
}
