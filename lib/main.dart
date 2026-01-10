import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'services/firebase_service.dart';
import 'services/sms_service.dart';
import 'services/trusted_contacts_service.dart';
import 'screens/trusted_contacts_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';
import 'widgets.dart';

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
      theme: AppTheme.lightTheme,
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const SafeHerHome();
        }

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
  
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      // Logout logic for "Profile/Settings" tab or just a button
      _showLogoutDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firebaseService.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

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
      await Geolocator.openAppSettings();
      return 'Location permission permanently denied. Please enable it from settings.';
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

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const AlertDialog(
              title: Text(
                '🚨 SOS Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Text(
                'Sending emergency SMS...',
                style: TextStyle(fontSize: 16),
              ),
            );
          },
        );
      }

      Map<String, bool> results =
          await _smsService.sendEmergencySms(
        trustedContactNumbers: phoneNumbers,
        userLocation: locationLink,
        customMessage: message,
      );

      int successCount =
          results.values.where((v) => v).length;

      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // close sending dialog
        }

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
                  onPressed: () => Navigator.pop(context),
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
    String userName = _firebaseService.getCurrentUserName() ?? 'User';

    final List<Widget> _pages = [
      // Home Page (SOS)
      _buildHomePage(userName),
      // Contacts Page
      const TrustedContactsScreen(),
    ];

    return Scaffold(
      body: _selectedIndex == 1 
          ? _pages[1] 
          : DecorativeBackground(child: _pages[0]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage(String userName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SafeHerLogo(size: 120),
          const SizedBox(height: 40),
          Text(
            'Hi, $userName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Are you in an emergency?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: triggerSOS,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                    offset: const Offset(0, 10),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 20,
                    spreadRadius: -10,
                    offset: Offset(-5, -5),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.touch_app,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Press the button to send alert',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
