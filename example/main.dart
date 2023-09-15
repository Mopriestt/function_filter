import 'package:function_filter/function_filter.dart';

void main() async {
  for (int i = 1; i <= 5; i++) {
    FunctionFilter.debounce(
      'debounceKey',
      Duration(milliseconds: 300),
      () => print('Debounced function called ($i)'),
    );
    await Future.delayed(const Duration(milliseconds: 200));
  }

  await Future.delayed(const Duration(milliseconds: 300));

  for (int i = 1; i <= 5; i++) {
    FunctionFilter.throttle(
      'throttleKey',
      Duration(milliseconds: 300),
      () => print('Throttled function called ($i)'),
    );
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
