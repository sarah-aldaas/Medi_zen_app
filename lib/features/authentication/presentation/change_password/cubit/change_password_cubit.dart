import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../../../../base/go_router/go_router.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  ChangePasswordCubit({required this.networkInfo}) : super(ChangePasswordInitial());

  Future<void> changePassword(
      String newPassword,
      String confirmPassword,
      BuildContext context, // Add context parameter
      ) async {
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    emit(ChangePasswordLoading());

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ChangePasswordFailure("No internet connection"));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    try {
      if (newPassword == confirmPassword) {
        // Add network call here if needed, e.g., authRemoteDataSource.changePassword()
        emit(ChangePasswordSuccess());
      } else {
        emit(ChangePasswordFailure("Passwords do not match."));
      }
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }
}