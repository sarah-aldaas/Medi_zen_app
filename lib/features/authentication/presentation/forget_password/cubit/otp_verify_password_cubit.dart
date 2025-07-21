import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:medizen_app/base/data/models/respons_model.dart';
import 'package:medizen_app/base/error/exception.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'otp_verify_password_state.dart';

class OtpVerifyPasswordCubit extends Cubit<OtpVerifyPasswordState> {
  final AuthRemoteDataSource authRemoteDataSource;

  OtpVerifyPasswordCubit({
    required this.authRemoteDataSource,
  }) : super(OtpVerifyPasswordInitial());

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required BuildContext context,
  }) async {
    emit(OtpLoadingVerify());
    try {
      final result = await authRemoteDataSource.verifyOtpPassword(
        email: email,
        otp: otp,
      );
      result.fold(
        success: (AuthResponseModel response) {
          if (response.status) {
            emit(OtpSuccess(message: response.msg.toString()));
          } else {
            String errorMessage = '';
            if (response.msg is Map<String, dynamic>) {
              (response.msg as Map<String, dynamic>).forEach((key, value) {
                if (value is List) {
                  errorMessage += value.join(', ');
                } else {
                  errorMessage += value.toString();
                }
              });
            } else if (response.msg is String) {
              errorMessage = response.msg;
            } else {
              errorMessage = 'Unknown error';
            }
            emit(OtpError(error: errorMessage));
          }
        },
        error: (String? message, int? code, AuthResponseModel? data) {
          emit(
            OtpError(error: data?.msg ?? message ?? 'OTP verification failed'),
          );
        },
      );
    } on ServerException catch (e) {
      emit(OtpError(error: e.message));
    } catch (e) {
      emit(OtpError(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}