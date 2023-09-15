import 'dart:async';

/// A class that accumulates function calls and triggers execution
/// when a specified number of calls occur within a given time duration.
class CallAggregator {
  /// The duration within which the required number of calls should be accumulated.
  final Duration _duration;

  /// The number of calls required to trigger execution of the provided function.
  final int _requiredCallCount;

  /// The function to execute when the required call count is reached within the duration.
  final Function _runnable;

  var _callCounter = 0;
  Timer? _resetTimer;

  /// Creates an [CallAggregator] instance.
  ///
  /// The [_duration] parameter specifies the time duration during which the
  /// required number of calls should be accumulated before execution.
  ///
  /// The [_requiredCallCount] parameter sets the number of calls required to
  /// trigger the execution of the [_runnable] function.
  ///
  /// The [_runnable] parameter is a callback function that will be executed
  /// when the required number of calls is accumulated within the specified duration.
  CallAggregator(this._duration, this._requiredCallCount, this._runnable);

  /// Accumulates a function call and triggers execution if the required call count is met.
  ///
  /// Each call to this method increments the call count. If the required number
  /// of calls is met within the specified [_duration], the [_runnable] function
  /// is executed. If the [_requiredCallCount] is not met within the duration,
  /// the accumulator is reset, and the execution is not triggered.
  void call() {
    if (_resetTimer == null) {
      _resetTimer = Timer(_duration, () {
        _callCounter = 0;
        _resetTimer = null;
      });
    }
    _callCounter++;
    if (_callCounter == _requiredCallCount) {
      _resetTimer?.cancel();
      _resetTimer = null;
      _callCounter = 0;

      _runnable();
    }
  }

  /// Resets the CallAggregator to abandon started call process.
  void reset() {
    _resetTimer?.cancel();
    _resetTimer = null;
  }
}
