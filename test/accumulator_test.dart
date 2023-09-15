import 'package:function_filter/accumulator.dart';
import 'package:test/test.dart';

import 'function_filter_test.dart';

void main() {
  test('basic_test', () async {
    var called = false;
    final accumulator = Accumulator(ms100, 5, () => called = true);

    for (int i = 0; i < 5; i++) {
      accumulator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    expect(called, true);
  });

  test('failed_to_call_test', () async {
    var called = false;
    final accumulator = Accumulator(ms100, 5, () => called = true);

    for (int i = 0; i < 5; i++) {
      accumulator.call();
      await Future.delayed(ms35);
    }

    expect(called, false);
  });
}
