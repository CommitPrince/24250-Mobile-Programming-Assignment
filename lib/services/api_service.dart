import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';

class ApiService {
  final String apiUrl = "https://your-api-endpoint.com/contacts";

  Future<void> sendContacts(List<Contact> contacts) async {
    List<Map<String, String>> contactData = contacts.map((contact) {
      String phoneNumber = '';
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        phoneNumber = contact.phones!.first.value ?? '';
      }

      return {
        "name": contact.displayName ?? "",
        "phone": phoneNumber,
      };
    }).toList();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(contactData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send contacts");
    }
  }
}
