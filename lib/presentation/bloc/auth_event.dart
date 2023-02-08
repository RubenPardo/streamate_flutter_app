abstract class AuthEvent{}


class AppStarted extends AuthEvent{}
class LogIn extends AuthEvent{
  final String redirectUri;
  LogIn({required this.redirectUri});
}
class Autorizarse extends AuthEvent{}
class LogOut extends AuthEvent{}