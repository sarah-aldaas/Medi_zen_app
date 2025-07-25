import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRemoteDataSource authRemoteDataSource;

  ResetPasswordCubit({
    required this.authRemoteDataSource,
  }) : super(ResetPasswordInitial());

  void resetPassword({
    required String email,
    required String newPassword,
    required BuildContext context,
  }) async {
    emit(ResetPasswordLoading());
    try {
      final result = await authRemoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
      );

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          emit(ResetPasswordSuccess(message: result.data.msg.toString()));
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
          emit(ResetPasswordFailure(error: errorMessage));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        emit(
          ResetPasswordFailure(error: result.message ?? 'An error occurred'),
        );
      }
    } on ServerException catch (e) {
      emit(ResetPasswordFailure(error: e.message));
    } catch (e) {
      emit(ResetPasswordFailure(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}