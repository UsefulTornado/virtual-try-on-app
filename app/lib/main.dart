import 'package:flutter/material.dart';
import 'package:tmp_app/pages/try_on.dart';


void main() {
  runApp(const TryOnApp());
}

class TryOnApp extends StatelessWidget {
  const TryOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual try on app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TryOnPage(title: 'Virtual try on app Home Page'),
    );
  }
}
