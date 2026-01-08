import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _apiTokenController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('实时语音识别')),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "输入Api Token"),
              controller: _apiTokenController,
            ),
          ],
        ),
      ),
    );
  }
}
