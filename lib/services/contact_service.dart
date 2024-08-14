import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  Future<List<Contact>> fetchContacts() async {
    // Request contacts permission
    var permissionStatus = await Permission.contacts.status;
    if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await Permission.contacts.request();
    }

    if (permissionStatus == PermissionStatus.granted) {
      // Fetch contacts
      Iterable<Contact> contacts = await ContactsService.getContacts();
      return contacts.toList();
    } else {
      throw Exception("Contacts permission denied");
    }
  }
}
