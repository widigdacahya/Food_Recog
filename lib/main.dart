import 'package:flutter/material.dart';
import 'package:foodrecog/ui/home_screen.dart';

void main() {
  runApp(const FoodRecognizerApp());
}

class FoodRecognizerApp extends StatelessWidget {
  const FoodRecognizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer - Chy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true
      ),
      home: HomeScreen(),
    );
  }
}



