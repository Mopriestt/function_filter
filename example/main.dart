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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            Text('$_counter'),
            SizedBox(height: 50),
            MaterialButton(
              onPressed: () => FunctionFilter.debounce(
                this,
                const Duration(milliseconds: 500),
                () {
                  setState(() {
                    ++_counter;
                  });
                },
              ),
              child: Text('Debounce +1'),
            ),
            SizedBox(height: 50),
            MaterialButton(
              onPressed: () => FunctionFilter.throttle(
                this,
                const Duration(milliseconds: 500),
                () {
                  setState(() {
                    ++_counter;
                  });
                },
              ),
              child: Text('Throttle +1'),
            ),
          ],
        ),
      ),
    );
  }
}
