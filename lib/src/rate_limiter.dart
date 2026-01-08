import 'dart:collection';
import 'dart:math';

/// A class that provides rate limiting functionality for a given function.
///
/// The [RateLimiter] class allows you to limit the number of times a function
/// can be executed within a specific time interval.
class RateLimiter {
  /// The time interval within which the maximum number of calls is enforced.
  final Duration interval;

  /// The maximum number of calls allowed within the [interval].
  final int maxCalls;

  /// Whether to replay queued calls when the token is replenished.
  ///
  /// If set to `true`, calls that exceed the rate limit are queued and executed
  /// when the rate limit window allows.
  final bool replay;

  final Queue<Function> _queue = Queue();
  int _token;
  int _stamp = 0;
  bool _disposed = false;

  /// Creates a [RateLimiter] instance with the specified [interval], [maxCalls], and optional [replay].
  ///
  /// The [interval] defines the time window.
  /// The [maxCalls] defines the maximum number of allowed executions within that window.
  /// The [replay] flag determines if excess calls should be queued and executed later.
  RateLimiter({
    required this.interval,
    required this.maxCalls,
    this.replay = false,
  }) : _token = maxCalls;

  void _scheduleReturn(int stamp) {
    Future.delayed(interval, () {
      if (_disposed || stamp != _stamp) return;
      _onTokenReturn();
    });
  }

  void _run(Function runnable) {
    if (interval == Duration.zero) {
      runnable();
      return;
    }
    try {
      runnable();
    } finally {
      _token--;
      _scheduleReturn(_stamp);
    }
  }

  void _onTokenReturn() {
    if (_disposed) return;

    _token = min(maxCalls, _token + 1);

    if (replay && _token > 0 && _queue.isNotEmpty) {
      final fn = _queue.removeFirst();
      _run(fn);
    }
  }

  /// Calls the rate-limited function.
  ///
  /// If the rate limit has not been exceeded, the [runnable] is executed immediately.
  /// If the limit is exceeded and [replay] is `true`, the [runnable] is queued.
  /// Otherwise, the call is ignored.
  void call(Function runnable) {
    if (_disposed) return;

    if (_token > 0) {
      _run(runnable);
    } else if (replay) {
      _queue.addLast(runnable);
    }
  }

  /// Resets the rate limiter, clearing any queued calls and restoring the call tokens.
  void reset() {
    _stamp++;
    _token = maxCalls;
    _queue.clear();
  }

  /// Clears any queued runnables without resetting the rate limiter state.
  void clearQueuedRunnables() => _queue.clear();

  /// Disposes the rate limiter, preventing any further execution of scheduled or queued calls.
  void dispose() {
    _disposed = true;
    _queue.clear();
    _stamp++;
  }
}
