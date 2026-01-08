import 'package:function_filter/function_filter.dart';
import 'package:test/test.dart';

import 'function_filter_test.dart';

void main() {
  test('basic_test', () async {
    var called = false;
    final aggregator = CallAggregator(ms100, 5, () => called = true);

    for (int i = 0; i < 5; i++) {
      aggregator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    expect(called, true);
  });

  test('failed_to_call_test', () async {
    var called = false;
    final aggregator = CallAggregator(ms100, 5, () => called = true);

    for (int i = 0; i < 5; i++) {
      aggregator.call();
      await Future.delayed(ms35);
    }

    expect(called, false);
  });

  test('dispose_test', () async {
    var called = false;
    final aggregator = CallAggregator(ms100, 5, () => called = true);

    // Call 4 times, technically it should not trigger callback
    for (int i = 0; i < 4; i++) {
      aggregator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Dispose the aggregator
    aggregator.dispose();

    // Call more times, it should not trigger callback either
    for (int i = 0; i < 10; i++) {
      aggregator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    expect(called, false);
  });

  test('reset_test', () async {
    var called = false;
    final aggregator = CallAggregator(ms100, 5, () => called = true);

    // Call 3 times
    for (int i = 0; i < 3; i++) {
      aggregator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Reset, should clear counter
    print('Resetting...');
    aggregator.reset();
    print('Reset done.');

    // Call 2 times. If counter was not cleared, total would be 5 and trigger callback
    for (int i = 0; i < 2; i++) {
      aggregator.call();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Expectation: Not called because counter should have been 0 + 2 = 2, not 3 + 2 = 5
    expect(called, false);
  });
}
