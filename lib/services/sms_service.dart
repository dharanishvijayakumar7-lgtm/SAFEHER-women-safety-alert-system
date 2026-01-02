import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SMSService {
  static final SMSService _instance = SMSService._internal();
  static const platform = MethodChannel('com.example.safeher/sms');

  factory SMSService() {
    return _instance;
  }

  SMSService._internal();

  /// Request SMS permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Check if SMS permission is granted
  Future<bool> isSmsPermissionGranted() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Send SMS to a single contact
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Check permission first
      bool hasPermission = await isSmsPermissionGranted();
      if (!hasPermission) {
        hasPermission = await requestSmsPermission();
        if (!hasPermission) {
          debugPrint('SMS permission not granted');
          return false;
        }
      }

      // Sanitize phone number (remove spaces, dashes, etc.)
      String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Send SMS using platform channel
      try {
        final bool result = await platform.invokeMethod<bool>(
          'sendSms',
          {
            'phoneNumber': sanitizedNumber,
            'message': message,
          },
        ) ?? false;

        debugPrint('SMS sent to $sanitizedNumber');
        return result;
      } on PlatformException catch (e) {
        debugPrint('Failed to send SMS: ${e.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception sending SMS: $e');
      return false;
    }
  }

  /// Send SMS to multiple contacts
  Future<bool> sendSmsToMultiple({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    try {
      // Check permission first
      bool hasPermission = await isSmsPermissionGranted();
      if (!hasPermission) {
        hasPermission = await requestSmsPermission();
        if (!hasPermission) {
          debugPrint('SMS permission not granted');
          return false;
        }
      }

      // Sanitize phone numbers
      List<String> sanitizedNumbers = phoneNumbers
          .map((number) => number.replaceAll(RegExp(r'[^0-9+]'), ''))
          .toList();

      // Send SMS to each contact
      for (final phoneNumber in sanitizedNumbers) {
        try {
          await platform.invokeMethod<bool>(
            'sendSms',
            {
              'phoneNumber': phoneNumber,
              'message': message,
            },
          );
          debugPrint('SMS sent to $phoneNumber');
        } catch (e) {
          debugPrint('Error sending SMS to $phoneNumber: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Exception sending SMS: $e');
      return false;
    }
  }

  /// Send emergency SMS to trusted contacts
  Future<Map<String, bool>> sendEmergencySms({
    required List<String> trustedContactNumbers,
    required String userLocation,
    String? customMessage,
  }) async {
    try {
      // Check permission first
      bool hasPermission = await isSmsPermissionGranted();
      if (!hasPermission) {
        hasPermission = await requestSmsPermission();
        if (!hasPermission) {
          debugPrint('SMS permission not granted');
          return {};
        }
      }

      String message = customMessage ??
          '🚨 EMERGENCY ALERT 🚨\n'
          'I need help immediately!\n'
          'My location: $userLocation\n'
          'Please contact me or call emergency services.\n'
          'Sent from SafeHer - Personal Safety App';

      Map<String, bool> results = {};

      for (String phoneNumber in trustedContactNumbers) {
        try {
          String sanitizedNumber =
              phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

          final bool result = await platform.invokeMethod<bool>(
            'sendSms',
            {
              'phoneNumber': sanitizedNumber,
              'message': message,
            },
          ) ?? false;

          debugPrint('Emergency SMS sent to $sanitizedNumber');
          results[phoneNumber] = result;
        } catch (e) {
          debugPrint('Exception sending SMS to $phoneNumber: $e');
          results[phoneNumber] = false;
        }
      }

      return results;
    } catch (e) {
      debugPrint('Exception in emergency SMS: $e');
      return {};
    }
  }
}
