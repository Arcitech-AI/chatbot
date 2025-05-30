  abstract class AuthState {}

  class AuthInitialState extends AuthState {}

  class AuthLoading extends AuthState {}

  class AuthRegistrationSucccess extends AuthState {}

  class AuthRegistrationFailed extends AuthState {
    String msg;
    AuthRegistrationFailed(this.msg);
  }

  class AuthLoginSuccess extends AuthState {}

  class AuthLoginFailed extends AuthState {
    String msg;
    AuthLoginFailed(this.msg);
  }

  class AuthLogoutState extends AuthState {}