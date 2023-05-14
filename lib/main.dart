import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OpenAiDropDown(),
    );
  }
}

class OpenAiDropDown extends StatefulWidget {
  @override
  _OpenAiDropDownState createState() => _OpenAiDropDownState();
}

class _OpenAiDropDownState extends State<OpenAiDropDown> {
  String res = '';
  List<String> _models = [];
  String _selectedModel = 'text-davinci-002';
  String _question = '';

  Future<void> _getModels() async {
    final headers = {'Authorization': 'Bearer your-api-key'};
    final response = await http.get(
      Uri.parse('https://api.openai.com/v1/models'),
      headers: headers,
    );
    final jsonBody = json.decode(response.body);
    final models = List<String>.from(
        jsonBody['data'].map((model) => model['id'].toString()));
    setState(() {
      _models = models;
      _selectedModel = models[0];
    });
  }

  Future<void> _getTextCompletion(String model, String prompt) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer your-api-key',
    };
    final data = {
      "model": model,
      "prompt": "Q: $prompt",
      "temperature": 0,
      "max_tokens": 60,
      "top_p": 1.0,
      "frequency_penalty": 0.0,
      "presence_penalty": 0.0
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: headers,
        body: json.encode(data),
      );
      final jsonBody = json.decode(response.body);
      print(jsonBody);
      if (jsonBody['choices'] != null && jsonBody['choices'].isNotEmpty) {
        final text = jsonBody['choices'][0]['text'].toString();
        setState(() {
          res = text;
        });
        print(res);
      } else {
        print('No completion choices returned');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getModels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI API'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  res,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButton<String>(
                value: _selectedModel,
                items: _models
                    .map<DropdownMenuItem<String>>(
                      (model) => DropdownMenuItem<String>(
                        value: model,
                        child: Text(model),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value!;
                    print(_selectedModel);
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a question',
                ),
                onChanged: (value) {
                  setState(() {
                    _question = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _getTextCompletion(_selectedModel, _question);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
