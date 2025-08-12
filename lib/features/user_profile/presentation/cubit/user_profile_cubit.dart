import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_details.dart';
import '../../domain/usecases/get_current_user_details_usecase.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final GetCurrentUserDetailsUseCase _getCurrentUserDetailsUseCase;

  UserProfileCubit(this._getCurrentUserDetailsUseCase) : super(const UserProfileState());

  Future<void> fetchUserDetails() async {
    emit(state.copyWith(status: UserProfileStatus.loading));

    final result = await _getCurrentUserDetailsUseCase(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        if (isClosed) return;
        emit(state.copyWith(
          status: UserProfileStatus.success,
          user: user,
        ));
      },
    );
  }
}