import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {

  ChangePasswordCubit() : super(ChangePasswordInitial());

  Future<void> changePassword(
      String newPassword,
      String confirmPassword,
      BuildContext context,
      ) async {
    emit(ChangePasswordLoading());
    try {
      if (newPassword == confirmPassword) {
        emit(ChangePasswordSuccess());
      } else {
        emit(ChangePasswordFailure("Passwords do not match."));
      }
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }
}