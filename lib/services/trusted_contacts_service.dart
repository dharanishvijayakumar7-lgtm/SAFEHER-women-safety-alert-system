import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final DateTime createdAt;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.createdAt,
  });

  factory TrustedContact.fromMap(Map<String, dynamic> map, String id) {
    return TrustedContact(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      relationship: map['relationship'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TrustedContactsService {
  static final TrustedContactsService _instance = TrustedContactsService._internal();

  factory TrustedContactsService() {
    return _instance;
  }

  TrustedContactsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a trusted contact
  Future<void> addTrustedContact({
    required String userId,
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trustedContacts')
          .add({
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding trusted contact: $e');
      rethrow;
    }
  }

  /// Get all trusted contacts for a user
  Future<List<TrustedContact>> getTrustedContacts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trustedContacts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrustedContact.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting trusted contacts: $e');
      return [];
    }
  }

  /// Update a trusted contact
  Future<void> updateTrustedContact({
    required String userId,
    required String contactId,
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trustedContacts')
          .doc(contactId)
          .update({
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
      });
    } catch (e) {
      debugPrint('Error updating trusted contact: $e');
      rethrow;
    }
  }

  /// Delete a trusted contact
  Future<void> deleteTrustedContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trustedContacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting trusted contact: $e');
      rethrow;
    }
  }

  /// Stream of trusted contacts (real-time updates)
  Stream<List<TrustedContact>> getTrustedContactsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trustedContacts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrustedContact.fromMap(
                doc.data(), doc.id))
            .toList());
  }
}
