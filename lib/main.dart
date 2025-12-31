import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const SafeHerApp());
}

/* -------------------- APP ROOT -------------------- */

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

/* -------------------- HOME SCREEN -------------------- */

class SafeHerHome extends StatefulWidget {
  const SafeHerHome({super.key});

  @override
  State<SafeHerHome> createState() => _SafeHerHomeState();
}

class _SafeHerHomeState extends State<SafeHerHome> {
  String statusText = 'SAFEHER – Women Safety Alert App';

  void triggerSOS() async {
  String locationLink = await getCurrentLocation();

  setState(() {
    statusText =
        '🚨 SOS TRIGGERED 🚨\n\nLocation:\n$locationLink';
  });

  debugPrint('SOS Triggered');
  debugPrint(locationLink);
}

  Future<String> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return 'Location services are disabled';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return 'Location permission denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return 'Location permission permanently denied';
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
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
            const SizedBox(height: 30),

            // Manage Contacts Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EmergencyContactsScreen(),
                  ),
                );
              },
              child: const Text('Manage Emergency Contacts'),
            ),

            const SizedBox(height: 20),

            // SOS Button
            ElevatedButton(
              onPressed: triggerSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
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

/* -------------------- EMERGENCY CONTACTS SCREEN -------------------- */

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  List<Map<String, String>> contacts = [];

  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController phoneController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedContacts =
        prefs.getStringList('contacts');

    if (storedContacts != null) {
      setState(() {
        contacts = storedContacts
            .map((e) => Map<String, String>.from(
                Uri.splitQueryString(e)))
            .toList();
      });
    }
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedContacts = contacts
        .map((e) => Uri(queryParameters: e).query)
        .toList();
    await prefs.setStringList('contacts', encodedContacts);
  }

  void addContact() {
    if (nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty) {
      setState(() {
        contacts.add({
          'name': nameController.text,
          'phone': phoneController.text,
        });
      });

      saveContacts();

      nameController.clear();
      phoneController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: addContact,
              child: const Text('Add Contact'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(contacts[index]['name']!),
                    subtitle: Text(contacts[index]['phone']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
