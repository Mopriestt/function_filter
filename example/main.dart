import 'package:flutter/material.dart';
import 'package:function_filter/function_filter.dart';

void main() {
  runApp(const MaterialApp(home: DemoApp()));
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<StatefulWidget> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  var _counter = 0;

  // Call Aggregator: Triggers only after 5 calls within 2 seconds
  late final _aggregator = CallAggregator(
    const Duration(seconds: 2),
    5,
    () => setState(() => _counter++),
  );

  // Rate Limiter: Allows max 3 calls every 5 seconds, replays blocked calls
  late final _rateLimiter = RateLimiter(
    interval: const Duration(seconds: 5),
    maxCalls: 3,
    replay: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Function Filter Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 50),

            // Debounce Example
            _buildButton(
              'Debounce (0.5s)',
              () => FunctionFilter.debounce(
                this,
                const Duration(milliseconds: 500),
                () => setState(() => _counter++),
              ),
            ),

            // Throttle Example
            _buildButton(
              'Throttle (1s)',
              () => FunctionFilter.throttle(
                this,
                const Duration(seconds: 1),
                () => setState(() => _counter++),
              ),
            ),

            // Call Aggregator Example
            _buildButton(
              'Aggregator (5 taps / 2s)',
              () => _aggregator.call(),
            ),

            // Rate Limiter Example
            _buildButton(
              'Rate Limit (3 taps / 5s)',
              () => _rateLimiter.call(() => setState(() => _counter++)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    _aggregator.reset();
    _rateLimiter.dispose();
    super.dispose();
  }
}
