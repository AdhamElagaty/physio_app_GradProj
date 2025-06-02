import 'package:bloc/bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/sign_up_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/signup/sign_up_event.dart';
import 'package:gradproject/features/auth/presentation/manager/signup/sign_up_state.dart';

class SignupBloc extends Bloc<AuthSignupEvent, AuthSigupState> {
  SignUpUseCase signUpUseCase;
  SignupBloc(this.signUpUseCase) : super(AuthSignupInit()) {
    on<AuthSignupEvent>((event, emit) {});
    on<SignupEvent>((event, emit) async {
      state.copyWith(requestState: RequestState.loading);
      var data = await signUpUseCase.call(event.signUpEntity);

      data.fold((l) {
        emit(state.copyWith(
          signedUp: false,
          requestState: RequestState.error,
          errorMessage: l.message,
        ));
      }, (r) {
        emit(
            state.copyWith(signedUp: true, requestState: RequestState.success));
      });
    });
  }
}
