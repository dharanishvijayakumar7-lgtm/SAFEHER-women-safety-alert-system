import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /* -------- LOCATION -------- */

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

  /* -------- SMS SENDING -------- */

  Future<void> sendSMS(String message) async {
  const String phoneNumber = '+916361754795'; // <-- your number

  final Uri smsUri = Uri.parse(
    'sms:$phoneNumber?body=${Uri.encodeComponent(message)}',
  );

  await launchUrl(
    smsUri,
    mode: LaunchMode.externalApplication,
  );
}


  /* -------- SOS TRIGGER -------- */

  void triggerSOS() async {
    String locationLink = await getCurrentLocation();

    String message = '''
🚨 EMERGENCY ALERT 🚨
I am in danger. Please help me.

My live location:
$locationLink
''';

    await sendSMS(message);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🚨 SOS Triggered',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            'Emergency SMS has been prepared.\n\nPlease press SEND in the SMS app.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /* -------- UI -------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEBEE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 90,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SAFEHER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Women Safety Alert System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                GestureDetector(
                  onTap: triggerSOS,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmergencyContactsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.contacts),
                  label: const Text(
                    'Manage Emergency Contacts',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('contacts');

    if (stored != null) {
      setState(() {
        contacts = stored
            .map((e) =>
                Map<String, String>.from(Uri.splitQueryString(e)))
            .toList();
      });
    }
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = contacts
        .map((e) => Uri(queryParameters: e).query)
        .toList();
    await prefs.setStringList('contacts', encoded);
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
              decoration:
                  const InputDecoration(labelText: 'Contact Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone Number'),
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
