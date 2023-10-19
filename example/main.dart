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
  late final _aggregator = CallAggregator(
    const Duration(seconds: 2),
    5,
    () => setState(() => _counter++),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text('$_counter'),
            const SizedBox(height: 50),
            MaterialButton(
              onPressed: () => FunctionFilter.debounce(
                this,
                const Duration(seconds: 1),
                () => setState(() => _counter++),
              ),
              child: const Text('Debounce +1'),
            ),
            const SizedBox(height: 50),
            MaterialButton(
              onPressed: () => FunctionFilter.throttle(
                this,
                const Duration(seconds: 1),
                () => setState(() => _counter++),
              ),
              child: const Text('Throttle +1'),
            ),
            const SizedBox(height: 50),
            MaterialButton(
              onPressed: () => _aggregator.call(),
              child: const Text('click 5 times in 2 seconds'),
            ),
          ],
        ),
      ),
    );
  }
}
