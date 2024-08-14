import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/contact_service.dart';
import '../services/api_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'contact_list_page.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Contacts'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await _requestPermission();
              List<Contact> contacts = await ContactService().fetchContacts();
              await ApiService().sendContacts(contacts);
              Fluttertoast.showToast(msg: "Contacts synced successfully!");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactListPage()),
              );
            } catch (e) {
              Fluttertoast.showToast(msg: "Failed to sync contacts: $e");
            }
          },
          child: Text('Sync Contacts'),
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    if (!status.isGranted) {
      throw Exception("Contacts permission denied");
    }
  }
}
