import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:math';

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

class JsEventStream {
  final StreamController<String> _controller = StreamController<String>();

  JsEventStream() {
    _startListening();
  }

  Stream<String> get stream => _controller.stream;

  void _startListening() {
    js.context['resultEmitter'].callMethod('addEventListener', [
      'newResult',
      js.allowInterop((event) {
        final result = js_util.getProperty(event, 'detail');
        _controller.add(result);
      })
    ]);
  }

  Future<void> findMistakes(
      String locale, String text, List<String> dictionary) async {
    final jsDictionary = js.JsObject.jsify(dictionary);
    js.context.callMethod(
        'postMessageToFindMistakesWorker', [locale, text, jsDictionary]);
  }

  void dispose() {
    _controller.close();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final JsEventStream _jsEventStream;

  @override
  void initState() {
    super.initState();
    _jsEventStream = JsEventStream();
  }

  @override
  void dispose() {
    _jsEventStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await _jsEventStream.findMistakes(
                    'en', 'test${Random().nextInt(100)}', ['hello', 'world']);
              },
              child: const Text('Start Processing'),
            ),
            const Text('Processed Results:'),
            StreamBuilder<String>(
              stream: _jsEventStream.stream,
              builder: (context, snapshot) {
                return Text(snapshot.data ?? 'Waiting for results...');
              },
            ),
          ],
        ),
      ),
    );
  }
}
