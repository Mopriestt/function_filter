/// A class that provides throttle functionality for a given function.
///
/// The [Throttler] class allows you to create a throttled function, which will
/// limit the rate at which the provided function can be executed. It ensures that
/// the function is executed no more frequently than a specified duration.
class Throttler {
  late final Duration _duration;
  Function? _runnable;
  var _locked = false;
  var _stamp = 0;

  /// Creates a [Throttler] instance with the specified [duration] and [runnable] function.
  ///
  /// The [duration] parameter defines the minimum time interval between successive
  /// executions of the [runnable] function. If a call to [call] is made within this
  /// duration, the call will be ignored until the duration has elapsed.
  ///
  /// The [runnable] parameter is the function to be executed after throttling.
  Throttler(Duration duration, Function runnable) {
    _runnable = runnable;
    _duration = duration;
  }

  /// Calls the throttled function.
  ///
  /// This method can be called whenever you want to trigger the execution of the
  /// [_runnable] function. However, it ensures that the function is executed no more
  /// frequently than the specified [_duration]. If multiple calls are made to [call]
  /// within the throttle duration, only the first call will result in the execution
  /// of the [_runnable] function, and subsequent calls will be ignored until the
  /// [_duration] has passed.
  void call() {
    if (_runnable == null) return;
    if (_duration == Duration.zero) {
      _runnable!();
      return;
    }

    if (_locked) return;

    _runnable!();
    _locked = true;
    final currentStamp = _stamp;
    Future.delayed(_duration, () {
      if (_stamp == currentStamp) _locked = false;
    });
  }

  /// Resets the throttle, allowing the [_runnable] function to be executed immediately.
  void reset() {
    _locked = false;
    _stamp++;
  }

  /// Dispose the throttler and prevent future calls.
  void dispose() => _runnable = null;
}
