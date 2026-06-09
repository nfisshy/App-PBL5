abstract final class ApiConstants {
  static const baseApiUrl = 'https://api.signlanguage.com';
  static const audioApiUrl =
      'https://lequanganhkhoa2005--speech-to-pose-server-api-dev.modal.run';

  static const loginEndpoint = '/auth/login';
  static const contactsEndpoint = '/contacts';
  static const speechToPoseEndpoint = '/speech-to-pose';
  static const speechToPoseRawEndpoint = '/speech-to-pose-raw';
  static const callEndpoint = '/call';

  static const availableEndpoints = [
    loginEndpoint,
    contactsEndpoint,
    speechToPoseEndpoint,
    speechToPoseRawEndpoint,
    callEndpoint,
  ];
}
