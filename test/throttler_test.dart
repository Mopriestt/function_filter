import 'package:function_filter/function_filter.dart';
import 'package:test/test.dart';

import 'function_filter_test.dart';

void main() {
  test('basic_test', () async {
    var callCounter = 0;
    final throttledCall = Throttler(ms100, () => callCounter++);
    for (int i = 0; i < 10; i++) {
      throttledCall.call();
      await Future.delayed(ms35);
    }

    // Called time:
    // 0(✓) - 35 - 70 - 105(✓) - 140 - 185 - 210(✓) - 245 - 280 - 315(✓)
    expect(callCounter, 4);
  });

  test('zero_duration_test', () {
    var callCounter = 0;
    final throttledCall = Throttler(Duration.zero, () => callCounter++);
    for (int i = 0; i < 10; i++) {
      throttledCall.call();
    }

    expect(callCounter, 10);
  });

  test('dispose_test', () async {
    var callCounter = 0;
    final throttledCall = Throttler(ms100, () => callCounter++);
    for (int i = 0; i < 10; i++) {
      throttledCall.call();
      await Future.delayed(ms35);
      if (i == 5) throttledCall.dispose();
    }

    expect(callCounter, 2);
  });

  test('reset_test', () async {
    var callCounter = 0;
    // 100ms throttle
    final throttler = Throttler(ms100, () => callCounter++);

    // T=0: Call 1. Executed. Locked until T=100.
    throttler.call();
    expect(callCounter, 1);

    // T=50: Wait.
    await Future.delayed(ms50);

    // T=50: Reset. Locked=False.
    throttler.reset();

    // T=50: Call 2. Executed (since reset). Locked until T=150.
    throttler.call();
    expect(callCounter, 2);

    // T=110: Wait 60ms. Total elapsed = 110ms.
    await Future.delayed(const Duration(milliseconds: 60));

    // T=110: Call 3. Should be throttled (since T < 150).
    throttler.call();

    expect(callCounter, 2, reason: 'Should be throttled until T=150');
  });
}
