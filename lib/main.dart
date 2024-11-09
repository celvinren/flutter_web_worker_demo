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
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>();

  JsEventStream() {
    _startListening();
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void _startListening() {
    js.context['resultEmitter'].callMethod('addEventListener', [
      'newResult',
      js.allowInterop((event) {
        // Retrieve the JavaScript object and convert it to a Dart map
        final jsResult = js_util.getProperty(event, 'detail');
        final text = js_util.getProperty(jsResult, 'text');
        final dictionary =
            List<String>.from(js_util.getProperty(jsResult, 'dictionary'));
        final checkedWords =
            List<String>.from(js_util.getProperty(jsResult, 'checkedWords'));
        debugPrint('Text: $text');
        debugPrint('Dictionary: $dictionary');
        debugPrint('Checked Words: $checkedWords');
        // final dartResult = _jsObjectToMap(jsResult);
        // _controller.add(dartResult);
      })
    ]);
  }

  Future<void> findMistakes(
      String text, List<String> dictionary, Set<String> checkedWords) async {
    final jsDictionary = js.JsObject.jsify(dictionary);
    final jsCheckedWords = js.JsObject.jsify(checkedWords.toList());
    js.context.callMethod('postMessageToFindMistakesWorker',
        [text, jsDictionary, jsCheckedWords]);
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
                  'test${Random().nextInt(100)}',
                  ['hello', 'world'],
                  {'find'},
                );
              },
              child: const Text('Start Processing'),
            ),
            const Text('Processed Results:'),
            StreamBuilder<Map<String, dynamic>>(
              stream: _jsEventStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Text(
                    'Text: ${data['text']}\n'
                    'Dictionary: ${data['dictionary']}\n'
                    'Checked Words: ${data['checkedWords']}\n'
                    'Processed Text: ${data['processedText']}',
                  );
                } else {
                  return const Text('Waiting for results...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
