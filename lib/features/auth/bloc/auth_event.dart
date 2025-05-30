abstract class AuthEvent {}

class AuthRegisterUserEvent extends AuthEvent {
  String name;
  String email;
  String password;
  AuthRegisterUserEvent(this.name, this.email, this.password);
}


class AuthLoginUserEvent extends AuthEvent {
  String email;
  String password;
  AuthLoginUserEvent(this.email, this.password);
}