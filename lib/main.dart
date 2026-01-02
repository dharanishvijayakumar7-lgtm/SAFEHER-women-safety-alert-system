import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'services/firebase_service.dart';
import 'services/sms_service.dart';
import 'services/trusted_contacts_service.dart';
import 'screens/trusted_contacts_screen.dart';
import 'screens/login_screen.dart';
/* -------------------- MAIN ENTRY POINT -------------------- */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
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
      home: const AuthGate(),
    );
  }
}

/* -------------------- AUTH GATE -------------------- */

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const SafeHerHome();
        }

        // User is not logged in
        return const LoginScreen();
      },
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
  final SMSService _smsService = SMSService();
  final TrustedContactsService _contactsService = TrustedContactsService();
  final FirebaseService _firebaseService = FirebaseService();

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

  /* -------- SOS TRIGGER -------- */

  void triggerSOS() async {
    String userId = _firebaseService.getCurrentUserId() ?? '';
    
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      return;
    }

    try {
      String locationLink = await getCurrentLocation();
      List<TrustedContact> trustedContacts = 
          await _contactsService.getTrustedContacts(userId);

      if (trustedContacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add trusted contacts first'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      List<String> phoneNumbers = 
          trustedContacts.map((c) => c.phoneNumber).toList();

      String message = '''
🚨 EMERGENCY ALERT 🚨
I am in danger. Please help me immediately!

My live location:
$locationLink

Sent from SafeHer - Women Safety Alert System
''';

      // Show dialog before sending
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                '🚨 SOS Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Text(
                'Sending emergency SMS to ${trustedContacts.length} trusted contact(s)...',
                style: const TextStyle(fontSize: 16),
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

      // Send SMS to all trusted contacts
      Map<String, bool> results = await _smsService.sendEmergencySms(
        trustedContactNumbers: phoneNumbers,
        userLocation: locationLink,
        customMessage: message,
      );

      // Count successful sends
      int successCount = results.values.where((v) => v).length;

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        
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
              content: Text(
                'Emergency SMS sent to $successCount out of ${trustedContacts.length} contact(s).',
                style: const TextStyle(fontSize: 16),
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
    } catch (e) {
      debugPrint('Error triggering SOS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /* -------- UI -------- */

  @override
  Widget build(BuildContext context) {
    String? userId = _firebaseService.getCurrentUserId();
    String userName = _firebaseService.getCurrentUserName() ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFEHER'),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Hello, $userName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _firebaseService.logout();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
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
                          color: Colors.red.withValues(alpha: 0.4),
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
                            const TrustedContactsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.contacts),
                  label: const Text(
                    'Manage Trusted Contacts',
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

