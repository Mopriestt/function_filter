# Function Filter

[![Pub Version](https://img.shields.io/pub/v/function_filter?logo=dart)](https://pub.dev/packages/function_filter)
[![Pub Points](https://img.shields.io/pub/points/function_filter?logo=dart)](https://pub.dev/packages/function_filter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Mopriestt/function_filter/blob/master/LICENSE)

语言: [English](https://github.com/Mopriestt/function_filter/blob/master/README.md) | 中文

一个轻量级、零依赖的 Dart 函数执行频率控制库。它提供了强大的 **防抖 (Debounce)**、**节流 (Throttle)**、**限流(Rate Limiter)** 以及 **调用聚合 (Call Aggregation)** 工具。

与其他仅依赖字符串 ID （如easy_debounce）或引入沉重 Stream 实现（如 RxDart）的库不同，`function_filter` 既提供了便捷的**静态方法**，也提供了符合 OOP 工程实践的**对象包装器 (Wrappers)**，完美适配复杂的 Flutter 应用生命周期管理。

## 为什么选择 Function Filter?

| 特性 | function_filter | easy_debounce | RxDart |
| :--- |:---------------:| :---: | :---: |
| **静态调用** |        ✅        | ✅ | ❌ |
| **实例封装** |   ✅ (生命周期安全)    | ❌ | ✅ |
| **Key 类型** | **任意对象** (杜绝冲突) | 仅字符串 | N/A |
| **依赖体积** |     **轻量**      | 轻量 | 沉重 |
| **限流（Rate Limiter）** | ✅ **（滑动窗口模型）**  | ❌ | ⚠️（需手动组合） |
| **调用聚合** |        ✅        | ❌ | ✅ (Buffer) |

---

## 可视化原理

```text
Debounce (防抖 - Trailing):
事件流:   --a-b-c-------d--e----->
执行点:   --------------c-------e>
(每次调用都会重置计时器，仅在停止操作一段时间后执行)

Throttle (节流 - Leading):
事件流:   --a-b-c-------d--e----->
执行点:   --a-----------d-------->
(立即执行第一次，然后在冷却时间内忽略后续调用)
```

## 功能特性

* **Debouncer (防抖器):** 延迟函数执行，直到活动停止（适用于：搜索框输入）。
* **Throttler (节流器):** 强制限制最大执行频率（适用于：按钮防连点、滚动事件监听）。
* **RateLimiter (限流器):** 在较长时间段内限制执行次数，基于滑动窗口算法（适用于：API 速率限制）。
* **CallAggregator (调用聚合器):** 累积多次调用并批量触发（适用于：埋点日志上传）。
* **灵活易用:** 可在 **静态方法** (全局/快速) 或 **包装器模式** (封装/安全) 之间自由选择。

---

## 1. 快速开始：静态方法 (Static Methods)

适用于简单、全局或纯逻辑函数场景。

**🔥 专家技巧：** 你可以使用 *任意对象* 作为 Key，而不仅仅是字符串。直接传入 `this` 或 `Widget` 实例，可以从根本上杜绝跨组件的 ID 冲突！

### 防抖 (Debouncing - 搜索框示例)

```dart
import 'package:function_filter/function_filter.dart';

// 在 State 类或逻辑层中
void onSearchChanged(String query) {
  // 使用 `this` 作为 key 确保了防抖仅针对当前类实例生效。
  // 不需要担心与其他 Widget 的字符串 ID 发生冲突！
  FunctionFilter.debounce(
    this, 
    const Duration(milliseconds: 500),
    () {
      apiClient.search(query);
      print('正在搜索: $query');
    },
  );
}
```

### 节流 (Throttling - 按钮点击示例)

```dart
void onFabClicked() {
  // 针对该特定 ID 全局防止双击
  FunctionFilter.throttle(
    'submit-order-btn', 
    const Duration(seconds: 1),
    () {
      submitOrder();
      print('订单已提交!');
    },
  );
}
```

---

## 2. 进阶用法：包装器模式 (Wrappers - 推荐)

推荐在 Flutter Widget 中使用。通过将过滤器与 Widget 的生命周期 (`dispose`) 绑定，确保内存安全。

### 防抖器包装器 (Debouncer Wrapper)

```dart
class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // 1. 定义包装器
  late final Debouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    // 2. 初始化
    _searchDebouncer = Debouncer(
      const Duration(milliseconds: 500),
      // 回调逻辑可以在这里定义，也可以在 .call() 中动态传入
    );
  }

  @override
  void dispose() {
    // 3. 自动清理，防止 Timer 导致的内存泄漏
    _searchDebouncer.cancel();
    super.dispose();
  }

  void onTextChanged(String text) {
    // 4. 调用
    _searchDebouncer.call(() {
       print('Searching for: $text');
    });
  }
  
  // ... build method
}
```

### 调用聚合器 (CallAggregator)

非常适合批量处理网络请求或日志数据。

```dart
// 聚合调用：必须在 2 秒内积攒 5 次调用才会触发。如果超时，计数器将重置。
final logger = CallAggregator(
  const Duration(seconds: 2), 
  5, 
  () => print('批量上传日志中...')
);

// 高频调用
for (int i = 0; i < 10; i++) {
  logger.call(); 
  await Future.delayed(const Duration(milliseconds: 100));
}
```

### 限流器 (RateLimiter)

限制在特定时间窗口内的调用次数。

```dart
// 允许每 1 分钟最多调用 5 次
final rateLimiter = RateLimiter(
  interval: const Duration(minutes: 1), 
  maxCalls: 5,
  replay: true // 如果为 true，超出限制的调用将被加入队列，等待可用令牌时执行
);

void onApiCall() {
  rateLimiter.call(() => api.fetchData());
}
```

---

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  function_filter: ^2.3.5
```

## 贡献

如果你有任何问题或建议，欢迎在 [项目仓库](https://github.com/Mopriestt/function_filter) 中提交 Issue 或 Pull Request。

Happy Coding!
