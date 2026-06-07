import 'package:photomanager/features/contacts/domain/contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> getContacts();
}
