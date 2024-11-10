import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  final id = const Uuid().v4();
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void _startListening() {
    final eventType = 'newResult_$id';

    js.context['resultEmitter'].callMethod('addEventListener', [
      eventType,
      js.allowInterop((event) {
        // Retrieve the JavaScript object and convert it to a Dart map
        final jsResult = js_util.getProperty(event, 'detail');
        // final text = js_util.getProperty(jsResult, 'text');
        final newMistakesJS =
            List<dynamic>.from(js_util.getProperty(jsResult, 'newMistakes'));
        final newMistakes = newMistakesJS.map((e) {
          // debugPrint('Mistake: $e');
          // final test = js_util.getProperty(e, 'length');
          // debugPrint('Test: $test');
          return {
            'offset': js_util.getProperty(e, 'offset'),
            'length': js_util.getProperty(e, 'length'),
            'suggestions':
                List<String>.from(js_util.getProperty(e, 'suggestions')),
          };
        }).toList();

        final newCheckedWords =
            List<String>.from(js_util.getProperty(jsResult, 'newCheckedWords'));
        // debugPrint('results: $text');
        debugPrint('Dictionary: $newMistakes');
        // debugPrint('results: $results');
        debugPrint('Checked Words: $newCheckedWords');
        // final dartResult = _jsObjectToMap(jsResult);
        // _controller.add((
        //   newMistakes: newMistakes,
        //   newCheckedWords: newCheckedWords.toSet()
        // ));
      })
    ]);
  }

  Future<void> findMistakes(
      String text, List<String> dictionary, Set<String> checkedWords) async {
    final jsDictionary = js.JsObject.jsify(dictionary);
    final jsCheckedWords = js.JsObject.jsify(checkedWords.toList());
    js.context.callMethod('postMessageToFindMistakesWorker',
        [id, text, jsDictionary, jsCheckedWords]);
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
                  'Hallo warld tomarrow Tim',
                  ['hello', 'world', 'tomorrow', 'time'],
                  {'hello'},
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
