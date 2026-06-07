import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/contacts/data/mock_contact_repository.dart';

void main() {
  group('MockContactRepository', () {
    test('returns the configured contacts', () async {
      final repository = MockContactRepository();

      final contacts = await repository.getContacts();

      expect(contacts, hasLength(4));
      expect(
        contacts.map((contact) => contact.username),
        ['dat', 'linh', 'an', 'minh'],
      );
      expect(contacts.first.displayName, 'Nguyen Tien Dat');
    });

    test('returns an immutable contact list', () async {
      final repository = MockContactRepository();
      final contacts = await repository.getContacts();

      expect(
        () => contacts.add(contacts.first),
        throwsUnsupportedError,
      );
    });
  });
}
