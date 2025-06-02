enum RequestState { init, loading, success, error }

class AuthLoginState {
  final RequestState requestState;
  final bool loggedIn;
  final String errorMessage;
  final bool isPasswordVisible;

  AuthLoginState({
    this.requestState = RequestState.init,
    this.loggedIn = false,
    this.errorMessage = '',
    this.isPasswordVisible = false,
  });

  AuthLoginState copyWith({
    RequestState? requestState,
    bool? loggedIn,
    String? errorMessage,
    bool? isPasswordVisible,
  }) {
    return AuthLoginState(
      requestState: requestState ?? this.requestState,
      loggedIn: loggedIn ?? this.loggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}
