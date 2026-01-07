/// A Dart library for function filtering utilities.
///
/// This library provides utility functions for debouncing and throttling
/// functions, allowing you to control the rate at which functions are executed
/// based on time intervals.
library function_filter;

/// Static util functions
export 'src/function_filter.dart';

/// Function wrappers
export 'src/call_aggregator.dart';
export 'src/debouncer.dart';
export 'src/rate_limiter.dart';
export 'src/throttler.dart';
