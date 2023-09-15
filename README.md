A Dart library for function filtering utilities, providing tools for debouncing and throttling function executions based on time intervals. This library is well-tested and easy to use, making it a reliable choice for managing function execution rates.

## Features

 - Debouncer: Debounce function executions to delay their execution until a certain time has passed since the last invocation.
 - Throttler: Throttle function executions to limit their rate and ensure they are executed at most once within a specified interval.
 - CallAggregator: Accumulates function calls and triggers execution when a specified number of calls occur within a given time duration.
 - Offers both static function method and function wrapper for flexible usage.

## Basic Usage

Here are some basic examples of how to use the function_filter library with static methods.

### Debouncing
Debouncing is a technique to delay the execution of a function until a certain amount of time has passed since the last time it was invoked. It is useful in scenarios where you want to trigger an action only after the user has stopped performing a certain action, such as typing or scrolling.

````
import 'package:function_filter/function_filter.dart';

void main() {
  FunctionFilter.debounce(
    'somekey',
    Duration(milliseconds: 500),
    () {
      // Your debounced function logic here
      print('Debounced function called.');
    },
  );
}
````

### Throttling
Throttling limits the rate at which a function can be executed. It ensures that a function is executed at most once every specified interval. This is helpful when you want to limit the number of times a function can run, especially in scenarios like handling scroll events.

```
import 'package:function_filter/function_filter.dart';

void main() {
  FunctionFilter.throttle(
    'somekey',
    Duration(milliseconds: 500),
    () {
      // Your throttled function logic here
      print('Throttled function called.');
    },
  );
}
```

Please note that any key type is allowed for identifying functions in the debounce and throttle methods. You can use various types such as strings, numbers, objects, or any other value that helps uniquely identify your functions.

```

final objKey = Object(); // Can be string, number, object such as Widget or model etc.
FunctionFilter.throttle(
  objKey,
  Duration(milliseconds: 500),
  () => print('Throttled function called.'),
);
```

## Function Wrapper Examples
Here are examples to use function wrappers.

### Debouncer Wrapper

```
final debouncer = Debouncer(Duration(milliseconds: 500), () {
  print('Debounced function executed!');
});

// Trigger the debounced function multiple times in quick succession.
for (int i = 1; i <= 5; i ++) {
    debouncer.call();
    await Future.delayed(Duration(milliseconds: 300));
}
```

### Throttler Wrapper
```
final throttler = Throttler(Duration(milliseconds: 500), () {
  print('Throttled function executed!');
});

// Trigger the throttled function multiple times in quick succession.
for (int i = 1; i <= 5; i++) {
  throttler.call();
  await Future.delayed(Duration(milliseconds: 300));
}
```

### CallAggregator Wrapper
```
// Function will be executed if the aggregator gets called for 5 times within 2 seconds.
final aggregator = CallAggregator(Duration(seconds: 2), 5, () {
    print('Aggregated calls executed!')
});
for (int i = 0; i < 5; i++) {
  aggregator.call();
  await Future.delayed(const Duration(milliseconds: 10));
}
```