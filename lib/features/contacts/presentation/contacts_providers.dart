import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/features/contacts/data/mock_contact_repository.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/domain/contact_repository.dart';
import 'package:photomanager/features/contacts/domain/filter_contacts_use_case.dart';
import 'package:photomanager/features/contacts/domain/get_contacts_use_case.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return MockContactRepository();
});

final getContactsUseCaseProvider = Provider<GetContactsUseCase>((ref) {
  return GetContactsUseCase(ref.watch(contactRepositoryProvider));
});

final filterContactsUseCaseProvider = Provider<FilterContactsUseCase>((ref) {
  return const FilterContactsUseCase();
});

final contactsProvider =
    StateNotifierProvider<ContactsController, AsyncValue<List<Contact>>>((ref) {
  return ContactsController(ref.watch(getContactsUseCaseProvider));
});

final contactSearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final filteredContactsProvider =
    Provider.autoDispose<AsyncValue<List<Contact>>>(
  (ref) {
    final contacts = ref.watch(contactsProvider);
    final query = ref.watch(contactSearchQueryProvider);
    final filterContacts = ref.watch(filterContactsUseCaseProvider);

    return contacts.whenData(
      (items) => filterContacts(contacts: items, query: query),
    );
  },
);

final contactByUsernameProvider =
    Provider.autoDispose.family<AsyncValue<Contact?>, String>((ref, username) {
  return ref.watch(contactsProvider).whenData((contacts) {
    for (final contact in contacts) {
      if (contact.username == username) {
        return contact;
      }
    }

    return null;
  });
});

class ContactsController extends StateNotifier<AsyncValue<List<Contact>>> {
  ContactsController(this._getContacts) : super(const AsyncValue.loading()) {
    load();
  }

  final GetContactsUseCase _getContacts;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getContacts.call);
  }
}
