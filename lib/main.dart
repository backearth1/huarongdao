import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HuarongdaoApp());
}

class HuarongdaoApp extends StatelessWidget {
  const HuarongdaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数字华容道',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
