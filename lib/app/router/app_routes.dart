abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';

  // Reserved route paths for future feature implementations.
  static const contacts = '/contacts';
  static const contactDetails = '/contacts/:username';
  static const call = '/call/:username';
  static const conversation = '/conversation';
  static const conversationDetails = '/conversation/:conversationId';
  static const profile = '/profile';
  static const speech = '/speech';
  static const video = '/video';

  static String contactDetail(String username) => '/contacts/$username';
  static String callRoute(String username) => '/call/$username';
  static String conversationDetail(String conversationId) =>
      '/conversation/$conversationId';
}
