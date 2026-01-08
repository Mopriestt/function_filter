import 'package:function_filter/function_filter.dart';
import 'package:test/test.dart';

const ms100 = Duration(milliseconds: 100);
const ms50 = Duration(milliseconds: 50);
const ms35 = Duration(milliseconds: 35);

void main() {
  group('debounce', () {
    var callCounter = 0;
    void callback() => callCounter++;

    setUp(() => callCounter = 0);

    test('basic_test', () async {
      for (int i = 0; i < 5; i++) {
        FunctionFilter.debounce('key', ms100, callback);
        await Future.delayed(ms50);
      }
      await Future.delayed(ms100);

      expect(callCounter, 1);
    });

    test('basic_test_with_lambda', () async {
      for (int i = 0; i < 5; i++) {
        FunctionFilter.debounce('key', ms100, () => callCounter++);
        await Future.delayed(ms50);
      }
      await Future.delayed(ms100);

      expect(callCounter, 1);
    });

    test('no_debouncing', () async {
      for (int i = 0; i < 5; i++) {
        FunctionFilter.debounce('key', ms50, callback);
        await Future.delayed(ms100);
      }
      await Future.delayed(ms100);

      expect(callCounter, 5);
    });

    test('object_key', () async {
      var key = Object();
      for (int i = 0; i < 5; i++) {
        FunctionFilter.debounce(key, ms100, callback);
        await Future.delayed(ms50);
      }
      await Future.delayed(ms100);

      expect(callCounter, 1);
    });

    test('int_key', () async {
      for (int i = 0; i < 5; i++) {
        FunctionFilter.debounce(114514, ms100, callback);
        await Future.delayed(ms50);
      }
      await Future.delayed(ms100);

      expect(callCounter, 1);
    });

    test('reset_all_debounce', () async {
      FunctionFilter.debounce('key1', ms100, () => callCounter++);
      FunctionFilter.debounce('key2', ms100, () => callCounter++);
      await Future.delayed(ms35);

      FunctionFilter.resetAllDebounce();
      FunctionFilter.debounce('key1', ms35, () => callCounter--);
      FunctionFilter.debounce('key2', ms35, () => callCounter--);

      await Future.delayed(ms50);

      expect(callCounter, -2);
    });

    test('reset_single_debounce', () async {
      FunctionFilter.debounce('key', ms100, () => callCounter++);
      await Future.delayed(ms35);

      FunctionFilter.resetDebounce('key');
      FunctionFilter.debounce('key', ms35, () => callCounter--);

      await Future.delayed(ms50);

      expect(callCounter, -1);
    });
  });

  group('throttle', () {
    var callCounter = 0;
    void callback() => callCounter++;

    setUp(() => callCounter = 0);
    tearDown(() async => await Future.delayed(ms100)); // Clear event loop

    test('basic_test', () async {
      // Called time:
      // 0(✓) - 35 - 70 - 105(✓) - 140 - 185 - 210(✓) - 245 - 280 - 315(✓)
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle('key', ms100, callback);
        await Future.delayed(ms35);
      }

      expect(callCounter, 4);
    });

    test('basic_test_with_lambda', () async {
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle('key', ms100, () => callCounter++);
        await Future.delayed(ms35);
      }

      expect(callCounter, 4);
    });

    test('no_throttling', () async {
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle('key', ms35, callback);
        await Future.delayed(ms50);
      }

      expect(callCounter, 10);
    });

    test('object_key', () async {
      final key = Object();
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle(key, ms100, callback);
        await Future.delayed(ms35);
      }

      expect(callCounter, 4);
    });

    test('test_reset_all_throttling', () async {
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle('key1', ms100, callback);
        FunctionFilter.throttle('key2', ms100, callback);
        await Future.delayed(ms35);
        FunctionFilter.resetAllThrottle();
      }

      expect(callCounter, 20);
    });

    test('test_single_throttling', () async {
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle(1, ms100, callback);
        await Future.delayed(ms35);
        FunctionFilter.resetThrottle(1);
      }

      expect(callCounter, 10);
    });

    test('test_zero_duration_throttling', () {
      for (int i = 0; i < 10; i++) {
        FunctionFilter.throttle(1, Duration.zero, callback);
      }
      expect(callCounter, 10);
    });

    test('reset_key_test', () async {
      const key = 'key';
      // 1. Start throttle
      FunctionFilter.throttle(key, ms100, callback);
      expect(callCounter, 1, reason: 'First call runs');

      // 2. Wait half duration
      await Future.delayed(ms50);

      // 3. Reset
      FunctionFilter.resetThrottle(key);

      // 4. Start throttle again (should run)
      FunctionFilter.throttle(key, ms100, callback);
      expect(callCounter, 2, reason: 'Call runs after reset');

      // 5. Wait 60ms. Total 110ms from start.
      // The first throttle's timer (set at T=0 for 100ms) fires at T=100ms.
      // If buggy, it unlocks 'bug-key'.
      await Future.delayed(const Duration(milliseconds: 60));

      // 6. Try again. Should be blocked by the SECOND throttle (started at T=50ms, ends at T=150ms).
      // Current time: T=110ms.
      FunctionFilter.throttle(key, ms100, callback);

      expect(callCounter, 2,
          reason:
              'Third call should be throttled by the second throttle window');
    });
  });
}
