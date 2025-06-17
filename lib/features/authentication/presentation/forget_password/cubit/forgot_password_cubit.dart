import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:medizen_app/base/data/models/respons_model.dart';
import 'package:medizen_app/base/error/exception.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  ForgotPasswordCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(ForgotPasswordInitial());

  void sendResetLink(String email, BuildContext context) async {
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    emit(ForgotPasswordLoading());

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ForgotPasswordError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    try {
      final result = await authRemoteDataSource.forgetPassword(email: email);

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          emit(ForgotPasswordSuccess(message: result.data.msg.toString()));
        } else {
          String errorMessage = '';
          if (result.data.msg is Map<String, dynamic>) {
            (result.data.msg as Map<String, dynamic>).forEach((key, value) {
              if (value is List) {
                errorMessage += value.join(', ');
              } else {
                errorMessage += value.toString();
              }
            });
          } else if (result.data.msg is String) {
            errorMessage = result.data.msg;
          } else {
            errorMessage = 'Unknown error';
          }
          emit(ForgotPasswordError(error: errorMessage));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        emit(ForgotPasswordError(error: result.message ?? 'An error occurred'));
      }
    } on ServerException catch (e) {
      emit(ForgotPasswordError(error: e.message));
    } catch (e) {
      emit(ForgotPasswordError(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}