/// Function filter utilities for debouncing and throttling.
class FunctionFilter {
  static final _debouncerKeyToStamp = <dynamic, int>{};
  static var _stamp = 0;

  /// Debounces a function execution based on the specified [duration].
  ///
  /// The [key] is used to identify the function being debounced, and if
  /// multiple calls to [debounce] with the same [key] occur within the
  /// [duration], only the last one will be executed.
  static void debounce(dynamic key, Duration duration, Function runnable) {
    if (duration == Duration.zero) {
      runnable();
      return;
    }

    late final int callStamp;
    _debouncerKeyToStamp[key] = callStamp = _stamp++;

    Future.delayed(duration, () {
      if (_debouncerKeyToStamp[key] == callStamp) {
        _debouncerKeyToStamp.remove(key);
        runnable();
      }
    });
  }

  /// Resets all debounce states, clearing any pending debounced functions.
  static void resetAllDebounce() => _debouncerKeyToStamp.clear();

  /// Resets the debounce state for a specific [key], allowing the associated
  /// function to be debounced again.
  static void resetDebounce(dynamic key) => _debouncerKeyToStamp.remove(key);

  static final _throttleKeysToStamp = <dynamic, int>{};

  /// Throttles a function execution based on the specified [duration].
  ///
  /// The [key] is used to identify the function being throttled, and if
  /// multiple calls to [throttle] with the same [key] occur within the
  /// [duration], only the first one will be executed.
  static void throttle(dynamic key, Duration duration, Function runnable) {
    if (_throttleKeysToStamp.containsKey(key)) return;
    if (duration == Duration.zero) {
      runnable();
      return;
    }

    late final int callStamp;
    _throttleKeysToStamp[key] = callStamp = _stamp++;

    try {
      runnable();
    } finally {
      Future.delayed(duration, () {
        if (callStamp == _throttleKeysToStamp[key]) {
          _throttleKeysToStamp.remove(key);
        }
      });
    }
  }

  /// Resets all throttle states, allowing throttled functions to be executed again.
  static void resetAllThrottle() => _throttleKeysToStamp.clear();

  /// Resets the throttle state for a specific [key], allowing the associated
  /// function to be throttled again.
  static void resetThrottle(dynamic key) => _throttleKeysToStamp.remove(key);
}
