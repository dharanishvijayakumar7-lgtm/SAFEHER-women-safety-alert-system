import 'package:flutter/material.dart';

void main() {
  runApp(const SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAFEHER',
      home: const SafeHerHome(),
    );
  }
}

class SafeHerHome extends StatelessWidget {
  const SafeHerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFEHER'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          'SAFEHER – Women Safety Alert App',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
