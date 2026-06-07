import 'package:flutter/material.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    required this.contact,
    required this.onTap,
    super.key,
  });

  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(contact.displayName.characters.first.toUpperCase()),
      ),
      title: Text(contact.displayName),
      subtitle: Text('@${contact.username}'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
