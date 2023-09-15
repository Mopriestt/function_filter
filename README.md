A Dart library for function filtering utilities, providing tools for debouncing and throttling function executions based on time intervals. This library is well-tested and easy to use, making it a reliable choice for managing function execution rates.

## Features

 - Debouncing: Debounce function executions to delay their execution until a certain time has passed since the last invocation.

 - Throttling: Throttle function executions to limit their rate and ensure they are executed at most once within a specified interval.

## Usage

Here are some basic examples of how to use the function_filter library.

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

Throttling
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




