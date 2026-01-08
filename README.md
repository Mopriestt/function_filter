# Function Filter

[![Pub Version](https://img.shields.io/pub/v/function_filter?logo=dart)](https://pub.dev/packages/function_filter)
[![Pub Points](https://img.shields.io/pub/points/function_filter?logo=dart)](https://pub.dev/packages/function_filter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Mopriestt/function_filter/blob/master/LICENSE)

Language: English | [中文](https://github.com/Mopriestt/function_filter/blob/master/README-ZH.md)

A lightweight, zero-dependency Dart library for advanced function execution control. It provides robust **Debounce**, **Throttle**, **Rate Limiter** and **Call Aggregation** utilities.

Unlike other libraries that rely solely on string-based keys (like easy_debounce) or heavy Stream implementations (like RxDart), `function_filter` offers both **Static Methods** for quick usage and **Object Wrappers** for strict lifecycle management in complex Flutter apps.

## Why Function Filter?

| Feature |           function_filter            | easy_debounce | RxDart |
| :--- |:------------------------------------:| :---: | :---: |
| **Static Access** |                  ✅                   | ✅ | ❌ |
| **Object Wrappers** |          ✅ (Safe lifecycle)          | ❌ | ✅ |
| **Key Types** | **Any Object** (prevents collisions) | String Only | N/A |
| **Dependency Weight** |           **Lightweight**            | Lightweight | Heavy |
| **Rate Limiter** |     ✅ **(Sliding Window Based)**     | ❌ | ⚠️ *(Manual composition)* |
| **Call Aggregation** |                  ✅                   | ❌ | ✅ (Buffer) |

---

## Visual Guide

```text
Debounce (Trailing):
Events:   --a-b-c-------d--e----->
Output:   --------------c-------e>
(Resets timer on every call, executes only after a pause)

Throttle (Leading):
Events:   --a-b-c-------d--e----->
Output:   --a-----------d-------->
(Executes immediately, then ignores calls for a duration)
```

## Features

* **Debouncer:** Delay function execution until a pause in activity (e.g., Search Input).
* **Throttler:** Enforce a maximum execution rate (e.g., Button Clicks, Scroll Events).
* **RateLimiter:** Limit execution frequency over a longer period using a sliding window algorithm (e.g., API Rate Limits).
* **CallAggregator:** Accumulate calls and trigger in batches (e.g., Analytics Logging).
* **Flexible Usage:** Choose between **Static Methods** (global/quick) or **Wrappers** (encapsulated/safe).

---

## 1. Quick Start: Static Methods

Best for simple, global, or functional use cases.

**🔥 Pro Tip:** You can use *any* object as a key, not just Strings. Using `this` or a `Widget` instance prevents ID collisions across your app!

### Debouncing (Search Input)

```dart
import 'package:function_filter/function_filter.dart';

// Inside a State class or logical layer
void onSearchChanged(String query) {
  // Using `this` as the key ensures this debounce is unique to this class instance.
  // No need to worry about string collisions with other widgets!
  FunctionFilter.debounce(
    this, 
    const Duration(milliseconds: 500),
    () {
      apiClient.search(query);
      print('Searching for: $query');
    },
  );
}
```

### Throttling (Button Click)

```dart
void onFabClicked() {
  // Prevents double-clicks globally for this specific ID
  FunctionFilter.throttle(
    'submit-order-btn', 
    const Duration(seconds: 1),
    () {
      submitOrder();
      print('Order Submitted!');
    },
  );
}
```

---

## 2. Professional Usage: Wrappers (Recommended)

Best for Flutter Widgets where you want the filter to be tied to the widget's lifecycle (`dispose`).

### Debouncer Wrapper

```dart
class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // 1. Declare the wrapper
  late final Debouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    // 2. Initialize
    _searchDebouncer = Debouncer(
      const Duration(milliseconds: 500),
      // The callback logic can be defined here or dynamically passed in .call()
    );
  }

  @override
  void dispose() {
    // 3. Clean up automatically prevents memory leaks
    _searchDebouncer.cancel();
    super.dispose();
  }

  void onTextChanged(String text) {
    // 4. Invoke
    _searchDebouncer.call(() {
       print('Searching for: $text');
    });
  }
  
  // ... build method
}
```

### CallAggregator (Batch Processing)

Great for batching network requests or logs.

```dart
// Aggregates calls: triggers only when 5 calls happen within 2 seconds. If time expires, it resets.
final logger = CallAggregator(
  const Duration(seconds: 2), 
  5, 
  () => print('Batch uploading logs...')
);

// Simulate high frequency calls
for (int i = 0; i < 10; i++) {
  logger.call(); 
  await Future.delayed(const Duration(milliseconds: 100));
}
```

### Rate Limiter (Sliding Window)

Limit the number of calls within a specific time window.

```dart
// Allow max 5 calls every 1 minute
final rateLimiter = RateLimiter(
  interval: const Duration(minutes: 1), 
  maxCalls: 5,
  replay: true // If true, excess calls are queued and executed when tokens are available
);

void onApiCall() {
  rateLimiter.call(() {
    api.fetchData();
  });
}
```

---

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  function_filter: ^2.3.5
```

## Contribution

If you have any questions or suggestions, feel free to open an issue or contribute a Pull Request in the [project repository](https://github.com/Mopriestt/function_filter).

Enjoy coding!
