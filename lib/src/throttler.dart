/// A class that provides throttle functionality for a given function.
///
/// The [Throttler] class allows you to create a throttled function, which will
/// limit the rate at which the provided function can be executed. It ensures that
/// the function is executed no more frequently than a specified duration.
class Throttler {
  /// The duration to wait before allowing another execution of the provided function.
  final Duration _duration;

  /// The function to be executed after throttling.
  final Function _runnable;

  var _locked = false;

  /// Creates a [Throttler] instance with the specified [_duration] and [_runnable] function.
  ///
  /// The [_duration] parameter defines the minimum time interval between successive
  /// executions of the [_runnable] function. If a call to [call] is made within this
  /// duration, the call will be ignored until the duration has elapsed.
  ///
  /// The [_runnable] parameter is the function to be executed after throttling.
  Throttler(this._duration, this._runnable);

  /// Calls the throttled function.
  ///
  /// This method can be called whenever you want to trigger the execution of the
  /// [_runnable] function. However, it ensures that the function is executed no more
  /// frequently than the specified [_duration]. If multiple calls are made to [call]
  /// within the throttle duration, only the first call will result in the execution
  /// of the [_runnable] function, and subsequent calls will be ignored until the
  /// [_duration] has passed.
  void call() {
    if (_duration == Duration.zero) {
      _runnable();
      return;
    }

    if (_locked) return;

    _runnable();
    _locked = true;

    Future.delayed(_duration, () => _locked = false);
  }

  /// Resets the throttle, allowing the [_runnable] function to be executed immediately.

  void reset() => _locked = false;
}
