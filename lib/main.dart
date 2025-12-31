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

class SafeHerHome extends StatefulWidget {
  const SafeHerHome({super.key});

  @override
  State<SafeHerHome> createState() => _SafeHerHomeState();
}

class _SafeHerHomeState extends State<SafeHerHome> {
  String statusText = 'SAFEHER – Women Safety Alert App';

  void triggerSOS() {
    setState(() {
      statusText = '🚨 SOS TRIGGERED 🚨';
    });
    print('SOS Triggered');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFEHER'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: triggerSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

