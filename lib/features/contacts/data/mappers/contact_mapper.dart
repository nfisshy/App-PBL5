import 'package:photomanager/features/contacts/data/dtos/contact_dto.dart';
import 'package:photomanager/features/contacts/domain/contact.dart';

extension ContactDtoMapper on ContactDto {
  Contact toDomain() => Contact(username: username, displayName: displayName);
}

extension ContactMapper on Contact {
  ContactDto toDto() {
    return ContactDto(username: username, displayName: displayName);
  }
}
