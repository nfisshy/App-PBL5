import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/domain/filter_contacts_use_case.dart';

void main() {
  const filterContacts = FilterContactsUseCase();
  const contacts = [
    Contact(username: 'dat', displayName: 'Nguyen Tien Dat'),
    Contact(username: 'linh', displayName: 'Tran Thi Linh'),
    Contact(username: 'an', displayName: 'Le Van An'),
    Contact(username: 'minh', displayName: 'Pham Duc Minh'),
  ];

  group('FilterContactsUseCase', () {
    test('returns all contacts for an empty query', () {
      final result = filterContacts(contacts: contacts, query: '  ');

      expect(result, contacts);
    });

    test('filters by username case-insensitively', () {
      final result = filterContacts(contacts: contacts, query: 'LINH');

      expect(result.map((contact) => contact.username), ['linh']);
    });

    test('filters by partial display name case-insensitively', () {
      final result = filterContacts(contacts: contacts, query: 'duc');

      expect(result.map((contact) => contact.username), ['minh']);
    });

    test('returns an empty list when no contact matches', () {
      final result = filterContacts(contacts: contacts, query: 'unknown');

      expect(result, isEmpty);
    });
  });
}
