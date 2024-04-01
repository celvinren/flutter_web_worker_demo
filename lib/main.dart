import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final result = await webWorkerResult().asBroadcastStream().last;
                print('Value: $result');
              },
              child: const Text('Test'),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> webWorkerResult() async* {
    StreamController<int> controller = StreamController<int>();

    // check is Web Worker support
    if (Worker.supported) {
      // create Web Worker
      final worker = Worker('worker/worker.js');

      // send required data to Worker
      worker.postMessage({
        'data': 10,
        'a': 2,
        'b': 3,
      });

      // listen Worker result
      worker.onMessage.listen((event) {
        print('Received from worker: ${event.data}');
        // handle Worker result here
        final result = event.data is int ? event.data : null;
        if (result != null) {
          controller.add(result);
        }
        worker.terminate(); // end Worker
        controller.close(); // end Stream
      });
    } else {
      print('Web Workers are not supported in this environment.');
      controller.close(); // end Stream
    }

    yield* controller.stream;
  }
}
