import 'package:bloc/bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/login_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_event.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthLoginState> {
  LoginUseCase loginUseCase;
  AuthBloc(
    this.loginUseCase,
  ) : super(AuthLoginInit()) {
    on<AuthEvent>((event, emit) {});
    on<LoginEvent>((event, emit) async {
      state.copyWith(requestState: RequestState.loading);
      var data = await loginUseCase.call(event.email, event.password);
      data.fold((l) {
        emit(state.copyWith(
          loggedIn: false,
          requestState: RequestState.error,
          errorMessage: l.message,
        ));
      }, (r) {
        emit(state.copyWith(
          loggedIn: r,
          requestState: RequestState.success,
        ));
      });
    });
  }
}
