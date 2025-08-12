part of 'user_profile_cubit.dart';

enum UserProfileStatus { initial, loading, success, error }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserDetails? user;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserDetails? user,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}