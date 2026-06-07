import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';
import 'package:photomanager/features/contacts/presentation/contacts_providers.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';
import 'package:photomanager/shared/widgets/primary_button.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({
    required this.username,
    super.key,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(contactByUsernameProvider(username));

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Details')),
      body: contact.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load contact.'),
        ),
        data: (contact) => contact == null
            ? const Center(child: Text('Contact not found.'))
            : _ContactDetails(contact: contact),
      ),
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  child: Text(
                    contact.displayName.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  contact.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${contact.username}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Call',
                  onPressed: () => context.push(
                    AppRoutes.callRoute(contact.username),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
