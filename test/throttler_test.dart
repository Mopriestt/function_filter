import 'package:function_filter/throttler.dart';
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
}
