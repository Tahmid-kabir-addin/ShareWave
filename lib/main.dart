import 'package:flutter/material.dart';
import 'package:reddit/Theme/pallete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit',
      theme: Pallete.darkModeAppTheme,
      home: const SizedBox(

      ),
    );
  }
}
