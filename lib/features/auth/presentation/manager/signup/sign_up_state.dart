class AuthSigupState {
  RequestState? requestState;
  bool? signedUp;
  String? errorMessage;
  AuthSigupState({this.requestState, this.signedUp, this.errorMessage});

  AuthSigupState copyWith(
      {RequestState? requestState, bool? signedUp, String? errorMessage}) {
    return AuthSigupState(
        requestState: requestState ?? this.requestState,
        signedUp: signedUp ?? this.signedUp,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class AuthSignupInit extends AuthSigupState {
  AuthSignupInit()
      : super(
            requestState: RequestState.init, signedUp: false, errorMessage: "");
}

enum RequestState { init, loading, success, error }
