import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/domain/contact_repository.dart';

class GetContactsUseCase {
  const GetContactsUseCase(this._repository);

  final ContactRepository _repository;

  Future<List<Contact>> call() {
    return _repository.getContacts();
  }
}
