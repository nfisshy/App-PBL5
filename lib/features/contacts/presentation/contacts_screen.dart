import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/presentation/contact_list_tile.dart';
import 'package:photomanager/features/contacts/presentation/contacts_providers.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) {
    return ref.read(contactsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(filteredContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (query) {
                  ref.read(contactSearchQueryProvider.notifier).state = query;
                },
                decoration: const InputDecoration(
                  hintText: 'Search contacts',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: contacts.when(
                loading: () => const Center(child: AppLoadingIndicator()),
                error: (error, stackTrace) => _RefreshableMessage(
                  icon: Icons.error_outline,
                  message: 'Unable to load contacts.',
                  onRefresh: () => _refresh(ref),
                ),
                data: (items) => items.isEmpty
                    ? _RefreshableMessage(
                        icon: Icons.people_outline,
                        message: 'No contacts found.',
                        onRefresh: () => _refresh(ref),
                      )
                    : _ContactList(
                        contacts: items,
                        onRefresh: () => _refresh(ref),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  const _ContactList({
    required this.contacts,
    required this.onRefresh,
  });

  final List<Contact> contacts;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: contacts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ContactListTile(
            contact: contact,
            onTap: () =>
                context.push(AppRoutes.contactDetail(contact.username)),
          );
        },
      ),
    );
  }
}

class _RefreshableMessage extends StatelessWidget {
  const _RefreshableMessage({
    required this.icon,
    required this.message,
    required this.onRefresh,
  });

  final IconData icon;
  final String message;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48),
                const SizedBox(height: 12),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
