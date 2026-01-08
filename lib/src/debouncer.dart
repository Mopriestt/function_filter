/// A class that provides debounce functionality for a given function.
///
/// The [Debouncer] class allows you to create a debounced function, which will
/// delay the execution of the provided function until a certain duration has
/// passed since the last call to the debounced function.
class Debouncer {
  late final Duration _duration;
  Function? _runnable;
  var _stamp = 0;

  /// Creates a [Debouncer] instance with the specified [_duration] and [_runnable] function.
  ///
  /// The [_duration] parameter defines the duration to wait before executing the
  /// [_runnable] function after the last call to the debounced function.
  ///
  /// The [_runnable] parameter is the function to be executed after the debounce delay.
  Debouncer(Duration duration, Function runnable) {
    _runnable = runnable;
    _duration = duration;
  }

  /// Calls the debounced function.
  ///
  /// This method can be called whenever you want to trigger the execution of
  /// the [_runnable] function. However, the actual execution will be delayed
  /// by the specified [_duration]. If multiple calls are made to [call] within
  /// the debounce duration, only the last call will result in the execution
  /// of the [_runnable] function.
  void call() {
    if (_runnable == null) return;
    final callStamp = ++_stamp;
    Future.delayed(_duration, () {
      if (callStamp == _stamp) _runnable?.call();
    });
  }

  /// Cancel all tasks pending execution.
  void reset() => _stamp++;

  /// Dispose the Debouncer to free up resources.
  void dispose() => _runnable = null;
}
