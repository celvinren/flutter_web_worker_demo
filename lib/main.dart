// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js' as js;

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
                await findMistakes('en', 'test');
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
}

Future<String?> findMistakes(String locale, String text) async {
  final dataStream = _webWorkerResult(locale, text).asBroadcastStream();
  final result = await dataStream.last;
  return result;
}

Stream<String> _webWorkerResult(String locale, String text) async* {
  StreamController<String> controller = StreamController<String>();

  // check is Web Worker support
  js.context.callMethod('postMessageToFindMistakesWorker', [locale, text]);

  var result;
  // wait workerResult result
  while (js.context['foundMistakesResult'] == null || result == null) {
    result = js.context.callMethod('getResult');
    if (result == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  js.context.callMethod('deleteResult');
  // print('Result: original - ${imageData.length}');
  // print('Result: resized - ${result.length}');
  // handle Worker result here
  if (result != null) {
    controller.add(result);
    controller.close(); // end Stream
  }

  yield* controller.stream;
}
