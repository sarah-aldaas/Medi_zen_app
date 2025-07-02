import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:medizen_app/base/data/models/respons_model.dart';
import 'package:medizen_app/base/error/exception.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'otp_verify_password_state.dart';

class OtpVerifyPasswordCubit extends Cubit<OtpVerifyPasswordState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  OtpVerifyPasswordCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(OtpVerifyPasswordInitial());

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required BuildContext context, // Add context parameter
  }) async {
    emit(OtpLoadingVerify());

    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(OtpError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

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