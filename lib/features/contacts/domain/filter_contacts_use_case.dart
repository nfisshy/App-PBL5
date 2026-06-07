import 'package:photomanager/features/contacts/domain/contact.dart';

class FilterContactsUseCase {
  const FilterContactsUseCase();

  List<Contact> call({
    required List<Contact> contacts,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return contacts;
    }

    return contacts.where((contact) {
      return contact.username.toLowerCase().contains(normalizedQuery) ||
          contact.displayName.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }
}
