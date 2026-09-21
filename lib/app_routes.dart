class PextRoutes {
  static const home = '/home';
  static const training = '/training';
  static const favorites = '/favorites';
  static const dashboard = '/dashboard';
  static const chat = '/chat';
  static const profile = '/profile';
}

class PextRouteArgs {
  final bool admin;
  const PextRouteArgs({this.admin = false});
}
