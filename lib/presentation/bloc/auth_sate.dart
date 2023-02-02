import 'package:streamate_flutter_app/data/model/user.dart';

abstract class AuthState {}

class AuthUninitialized extends AuthState{}
class AuthAuthenticated extends AuthState{
  final User user;/// borrar- ----------------------------------
  AuthAuthenticated({required this.user});
}
class AuthAutorizacion extends AuthState{
  final String urlAutorizacion;
  AuthAutorizacion({required this.urlAutorizacion});
}
class AuthError extends AuthState{
  final String mensaje;

  AuthError({required this.mensaje});
}
class AuthUnauthenticated extends AuthState{}
class AuthLoading extends AuthState{}