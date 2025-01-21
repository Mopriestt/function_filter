# Function Filter

Language: [English](README.md) | 中文

一个用于函数过滤的 Dart 库，提供基于时间间隔的函数防抖（debounce）和节流（throttle）等执行工具。该库经过充分测试，使用简单，是管理函数执行速率的可靠选择。

---

## 功能特性

1. **Debouncer - 防抖**
   延迟函数执行，只有在最后一次调用之后经过指定时间才会执行，常用于用户停止输入、停止滚动后再触发操作的场景。

2. **Throttler - 节流**
   限制函数执行频率，保证在指定时间间隔内函数最多执行一次，可用于滚动、点击等需要限制执行频率的情况。

3. **CallAggregator - 聚合**
   用于累积调用次数，一旦在给定的时间内调用次数达到某个阈值，即触发执行一次。

4. 提供**静态函数方法**和**函数封装（Wrapper）**两种使用方式，灵活满足不同需求。

---

## 基础用法

下面示例展示如何使用 `function_filter` 库中的静态方法。

### 防抖（Debouncing）

防抖是在最后一次函数调用后等待一段时间再执行的技巧，通常用于在用户停止操作（如停止输入、停止滚动）之后再触发相应的处理逻辑。

```dart
import 'package:function_filter/function_filter.dart';

void main() {
  FunctionFilter.debounce(
    'somekey',
    Duration(milliseconds: 500),
    () {
      // 这里是防抖后的函数逻辑
      print('Debounced function called.');
    },
  );
}
```

### 节流（Throttling）

节流在指定间隔内只允许函数执行一次。适合在用户频繁触发某些事件（如滚动、点击）时，限制函数执行频率。

```dart
import 'package:function_filter/function_filter.dart';

void main() {
  FunctionFilter.throttle(
    'somekey',
    Duration(milliseconds: 500),
    () {
      // 这里是节流后的函数逻辑
      print('Throttled function called.');
    },
  );
}
```

> **注意**: 在 `debounce` 和 `throttle` 方法中，`key` 参数可以是任何类型（字符串、数字、对象等），只要能唯一标识要处理的函数即可。例如：

```dart
final objKey = Object(); // 可以是字符串、数字或其他实例
FunctionFilter.throttle(
  objKey,
  Duration(milliseconds: 500),
  () => print('Throttled function called.'),
);
```


### 函数封装示例

除了静态方法，function_filter 还支持对函数进行封装（Wrapper），方便在不同场景中复用。

#### Debouncer 封装

```dart
final debouncer = Debouncer(Duration(milliseconds: 500), () {
  print('Debounced function executed!');
});

// 连续多次快速调用
for (int i = 1; i <= 5; i ++) {
  debouncer.call();
  await Future.delayed(Duration(milliseconds: 300));
}
```

在上述示例中，只有当最后一次调用结束后经过 500 毫秒，才会真正执行函数。

#### Throttler 封装

```dart
final throttler = Throttler(Duration(milliseconds: 500), () {
  print('Throttled function executed!');
});

// 连续多次快速调用
for (int i = 1; i <= 5; i++) {
  throttler.call();
  await Future.delayed(Duration(milliseconds: 300));
}
```

这里，函数在 500 毫秒内只会执行一次。

#### CallAggregator 封装
```dart
// 如果在 2 秒内累计调用 5 次，则执行函数
final aggregator = CallAggregator(Duration(seconds: 2), 5, () {
  print('Aggregated calls executed!');
});

for (int i = 0; i < 5; i++) {
  aggregator.call();
  await Future.delayed(const Duration(milliseconds: 10));
}
```

当在指定时间（如 2 秒）内累计到达指定调用次数（如 5 次）后，会执行一次封装的函数。

如有任何问题或建议，欢迎在[项目仓库](https://github.com/Mopriestt/function_filter)提出 Issue 或贡献 Pull Request！祝使用愉快。