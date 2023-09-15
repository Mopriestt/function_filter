import 'package:function_filter/debouncer.dart';
import 'package:test/test.dart';

import 'function_filter_test.dart';

void main() {
  test('basic_test', () async {
    var callCounter = 0;
    final debouncedCall = Debouncer(ms50, () => callCounter++);
    for (int i = 0; i < 5; i++) {
      debouncedCall.call();
      await Future.delayed(ms35);
    }

    await Future.delayed(ms100);

    expect(callCounter, 1);
  });
}
