/// Function filter utilities for debouncing and throttling.
class FunctionFilter {
  static final _keyToStamp = <dynamic, int>{};
  static var _stamp = 0;

  /// Debounces a function execution based on the specified [duration].
  ///
  /// The [key] is used to identify the function being debounced, and if
  /// multiple calls to [debounce] with the same [key] occur within the
  /// [duration], only the last one will be executed.
  static void debounce(dynamic key, Duration duration, Function runnable) {
    late final int callStamp;
    _keyToStamp[key] = callStamp = _stamp++;

    Future.delayed(duration, () {
      if (_keyToStamp[key] == callStamp) {
        _keyToStamp.remove(key);
        runnable();
      }
    });
  }

  /// Resets all debounce states, clearing any pending debounced functions.
  static void resetAllDebounce() => _keyToStamp.clear();

  /// Resets the debounce state for a specific [key], allowing the associated
  /// function to be debounced again.
  static void resetDebounce(dynamic key) => _keyToStamp.remove(key);

  static final _throttleKeys = <dynamic>{};

  /// Throttles a function execution based on the specified [duration].
  ///
  /// The [key] is used to identify the function being throttled, and if
  /// multiple calls to [throttle] with the same [key] occur within the
  /// [duration], only the first one will be executed.
  static void throttle(dynamic key, Duration duration, Function runnable) {
    if (_throttleKeys.contains(key)) return;

    runnable();

    _throttleKeys.add(key);
    if (duration == Duration.zero) {
      _throttleKeys.remove(key);
    } else {
      Future.delayed(duration, () => _throttleKeys.remove(key));
    }
  }

  /// Resets all throttle states, allowing throttled functions to be executed again.
  static void resetAllThrottle() => _throttleKeys.clear();

  /// Resets the throttle state for a specific [key], allowing the associated
  /// function to be throttled again.
  static void resetThrottle(dynamic key) => _throttleKeys.remove(key);
}
