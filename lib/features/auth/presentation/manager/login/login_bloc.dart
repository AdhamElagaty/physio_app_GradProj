import 'package:bloc/bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/login_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_event.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_state.dart';

import 'package:bloc/bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/login_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_event.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthLoginState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthLoginState()) {
    on<LoginEvent>(_onLogin);
    on<PasswordVisibilityEvent>(_onTogglePasswordVisibility);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthLoginState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await loginUseCase.call(event.email, event.password);

    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        loggedIn: false,
        errorMessage: failure.message,
      )),
      (success) => emit(state.copyWith(
        requestState: RequestState.success,
        loggedIn: success,
      )),
    );
  }

  void _onTogglePasswordVisibility(
      PasswordVisibilityEvent event, Emitter<AuthLoginState> emit) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }
}
