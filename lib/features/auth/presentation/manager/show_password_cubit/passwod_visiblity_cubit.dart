import 'package:bloc/bloc.dart';

class ShowPasswordCubit extends Cubit<bool> {
  ShowPasswordCubit() : super(true); // true = password hidden

  void PasswordVisibility() => emit(!state);
}
