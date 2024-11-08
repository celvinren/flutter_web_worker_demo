import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<String> _resultStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    _startListeningForResults();
  }

  void _startListeningForResults() {
    // Listen for JavaScript `newResult` events
    js.context['resultEmitter'].callMethod('addEventListener', [
      'newResult',
      js.allowInterop((event) {
        final result = js_util.getProperty(event, 'detail');
        _resultStreamController.add(result);
      })
    ]);
  }

  @override
  void dispose() {
    _resultStreamController.close();
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
                await findMistakes('en', 'test', ['hello', 'world']);
              },
              child: const Text('Start Processing'),
            ),
            const Text('Processed Results:'),
            StreamBuilder<String>(
              stream: _resultStreamController.stream,
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

Future<void> findMistakes(String locale, String text, List<String> dic) async {
  final jsDic = js.JsObject.jsify(dic);
  js.context
      .callMethod('postMessageToFindMistakesWorker', [locale, text, jsDic]);
}
