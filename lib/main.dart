import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 63, 106, 58),
          brightness: Brightness.light,
          surface: const Color.fromARGB(255, 46, 74, 72),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 200, 220, 222),
      ),
      home: const GroceryList(),
    );
  }
}
