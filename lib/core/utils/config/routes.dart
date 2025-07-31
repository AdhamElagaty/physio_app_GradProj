class Routes {
  static const String login = '/login';
  static const String mainScreen = '/main-screen';
  static const String guestHome = '/guest-home';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String newPassword = '/new-password';

  // home
  static const String _baseHome = '/home';
  static const String exerciseFilter = '$_baseHome/exercise-filter';
  static const String exerciseDescription = '$_baseHome/exercise-description';
  bool isRouteHomeParent(String? route){
    return route != null && route.startsWith(_baseHome);
  }

  // chat bot
  static const String _baseChatBot = '/chat-bot-history';
  static const String chatBotChatScreen = '$_baseChatBot/chat-screen';
}
