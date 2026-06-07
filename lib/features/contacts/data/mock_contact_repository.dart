import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/domain/contact_repository.dart';

class MockContactRepository implements ContactRepository {
  static const _contacts = [
    Contact(
      username: 'dat',
      displayName: 'Nguyen Tien Dat',
    ),
    Contact(
      username: 'linh',
      displayName: 'Tran Thi Linh',
    ),
    Contact(
      username: 'an',
      displayName: 'Le Van An',
    ),
    Contact(
      username: 'minh',
      displayName: 'Pham Duc Minh',
    ),
  ];

  @override
  Future<List<Contact>> getContacts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<Contact>.unmodifiable(_contacts);
  }
}
