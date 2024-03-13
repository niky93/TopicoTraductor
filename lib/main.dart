import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Translation> translateWord(String word) async {
  const key = "trnsl.1.1.20240307T233437Z.afbc8c55de4cb781.39508c29ebb5c11ef7f56c6f17092cd94ee3cf33";

  final response = await http
      .post(Uri.parse('https://translate.yandex.net/api/v1.5/tr.json/translate?key=$key&text=$word&lang=es-en'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Translation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load translation');
  }
}

class Translation {
  final int code;
  final String lang;
  final List<String> text;

  const Translation({
    required this.code,
    required this.lang,
    required this.text,
  });
  factory Translation.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as int?;
    final lang = json['lang'] as String?;
    final text = json['text'] != null ? List<String>.from(json['text'] as List<dynamic>) : <String>[];

    if (code != null && lang != null && text.isNotEmpty) {
      return Translation(
        code: code,
        lang: lang,
        text: text,
      );
    } else {
      throw const FormatException('Failed to load translation.');
    }
  }



}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Traductor a Ingles',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor a Ingles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: myController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text the that user has entered by using the
                // TextEditingController.
                content: FutureBuilder<Translation>(
                  future: translateWord(myController.text),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.text[0]);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
              );
            },
          );
        },
        tooltip: 'Traducir al Ingles',
        child: const Icon(Icons.text_fields),
      ),
    );
  }
}