import 'package:flutter/material.dart';
import '../services/trusted_contacts_service.dart';
import '../services/firebase_service.dart';
import '../widgets.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final TrustedContactsService _contactsService = TrustedContactsService();
  final FirebaseService _firebaseService = FirebaseService();
  
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = _firebaseService.getCurrentUserId() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
      ),
      body: DecorativeBackground(
        child: StreamBuilder<List<TrustedContact>>(
          stream: _contactsService.getTrustedContactsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<TrustedContact> contacts = snapshot.data ?? [];

            if (contacts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contacts, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No trusted contacts yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddContactDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Contact'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                TrustedContact contact = contacts[index];
                return ContactListTile(
                  contact: contact,
                  onEdit: () => _showEditContactDialog(contact),
                  onDelete: () => _deleteContact(contact.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g., Mom, Sister, Friend)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  relationshipController.text.isNotEmpty) {
                _addContact(
                  nameController.text,
                  phoneController.text,
                  relationshipController.text,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(TrustedContact contact) {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phoneNumber);
    final relationshipController =
        TextEditingController(text: contact.relationship);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Trusted Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  relationshipController.text.isNotEmpty) {
                _updateContact(
                  contact.id,
                  nameController.text,
                  phoneController.text,
                  relationshipController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addContact(String name, String phone, String relationship) async {
    try {
      await _contactsService.addTrustedContact(
        userId: userId,
        name: name,
        phoneNumber: phone,
        relationship: relationship,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contact: $e')),
        );
      }
    }
  }

  void _updateContact(
      String id, String name, String phone, String relationship) async {
    try {
      await _contactsService.updateTrustedContact(
        userId: userId,
        contactId: id,
        name: name,
        phoneNumber: phone,
        relationship: relationship,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating contact: $e')),
        );
      }
    }
  }

  void _deleteContact(String id) async {
    try {
      await _contactsService.deleteTrustedContact(userId, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting contact: $e')),
        );
      }
    }
  }
}

class ContactListTile extends StatelessWidget {
  final TrustedContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(contact.phoneNumber),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contact.relationship,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
