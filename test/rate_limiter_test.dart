import 'package:function_filter/function_filter.dart';
import 'package:test/test.dart';

import 'function_filter_test.dart';

void main() {
  group('RateLimiter', () {
    test('basic_limiting', () {
      var callCounter = 0;
      // Allow 2 calls every 100ms
      final rateLimiter = RateLimiter(interval: ms100, maxCalls: 2);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      // First 2 calls should go through
      limitedCall();
      limitedCall();
      expect(callCounter, 2);

      // 3rd call should be ignored (replay: false by default)
      limitedCall();
      expect(callCounter, 2);
    });

    test('replenish_token', () async {
      var callCounter = 0;
      final rateLimiter = RateLimiter(interval: ms50, maxCalls: 1);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      limitedCall();
      expect(callCounter, 1);

      limitedCall();
      expect(callCounter, 1); // Ignored

      await Future.delayed(ms50);
      await Future.delayed(ms35); // Slight buffer

      limitedCall();
      expect(callCounter, 2); // Should work again
    });

    test('replay_true', () async {
      var callCounter = 0;
      final rateLimiter =
          RateLimiter(interval: ms50, maxCalls: 1, replay: true);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      limitedCall();
      expect(callCounter, 1);

      limitedCall();
      expect(callCounter, 1); // Queued

      await Future.delayed(ms50);
      await Future.delayed(ms35); // Wait for replenishment

      // The queued call should have run automatically
      expect(callCounter, 2);
    });

    test('reset', () {
      var callCounter = 0;
      final rateLimiter = RateLimiter(interval: ms100, maxCalls: 1);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      limitedCall();
      expect(callCounter, 1);

      limitedCall();
      expect(callCounter, 1); // Ignored

      rateLimiter.reset();

      limitedCall();
      expect(callCounter, 2); // Should work immediately after reset
    });

    test('dispose', () async {
      var callCounter = 0;
      final rateLimiter =
          RateLimiter(interval: ms50, maxCalls: 1, replay: true);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      limitedCall();
      limitedCall(); // Queued
      expect(callCounter, 1);

      rateLimiter.dispose();

      await Future.delayed(ms100);

      // Queued call should NOT have run
      expect(callCounter, 1);

      // Further calls should be ignored
      limitedCall();
      expect(callCounter, 1);
    });

    test('clearQueuedRunnables', () async {
      var callCounter = 0;
      final rateLimiter =
          RateLimiter(interval: ms50, maxCalls: 1, replay: true);
      final limitedCall = () => rateLimiter.call(() => callCounter++);

      limitedCall();
      limitedCall(); // Queued
      expect(callCounter, 1);

      rateLimiter.clearQueuedRunnables();

      await Future.delayed(ms100);

      // Queued call should NOT have run
      expect(callCounter, 1);
    });

    test('exception_handling', () async {
      var callCounter = 0;
      final rateLimiter = RateLimiter(interval: ms50, maxCalls: 1);
      final limitedCall = () => rateLimiter.call(() {
            callCounter++;
            throw Exception('Test Exception');
          });

      try {
        limitedCall();
      } catch (_) {}

      expect(callCounter, 1);

      // Token should be consumed even if exception thrown
      limitedCall();
      expect(callCounter, 1); // Ignored

      await Future.delayed(ms50);
      await Future.delayed(ms35);

      // Token should be returned
      try {
        limitedCall();
      } catch (_) {}
      expect(callCounter, 2);
    });
    test('max_buffered_calls', () async {
      var callCounter = 0;
      final rateLimiter = RateLimiter(
        interval: ms50,
        maxCalls: 1,
        replay: true,
        maxBufferedCalls: 2,
      );
      final limitedCall = (int id) => rateLimiter.call(() => callCounter += id);

      // 1. Consume the token
      limitedCall(1); // Executes immediately
      expect(callCounter, 1);

      // 2. Fill the queue (size 2)
      limitedCall(10); // Queued
      limitedCall(100); // Queued
      expect(callCounter, 1); // Still 1

      // 3. Overflow the queue
      // Queue is [10, 100]. maxReplaySize is 2.
      // Adding 1000 should drop 10 (oldest) and add 1000.
      // Queue becomes [100, 1000].
      limitedCall(1000);
      expect(callCounter, 1);

      await Future.delayed(ms50);
      await Future.delayed(ms35); // Wait for replenishment

      // The next call in queue (100) should run.
      // Queue has 1000 left.
      expect(callCounter, 101); // 1 + 100

      await Future.delayed(ms50);
      await Future.delayed(ms35);

      // The last call in queue (1000) should run.
      expect(callCounter, 1101); // 101 + 1000
    });
  });
}
