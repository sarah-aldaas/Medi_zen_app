import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/data/models/respons_model.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency
  Timer? _timer;

  OtpCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(OtpInitial());

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required BuildContext context, // Add context parameter
  }) async {
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    emit(OtpLoadingVerify());

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(OtpError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await authRemoteDataSource.verifyOtp(email: email, otp: otp);
    result.fold(
      success: (AuthResponseModel response) {
        if (response.status) {
          emit(OtpSuccess(message: response.msg));
        } else {
          emit(OtpError(error: response.msg));
        }
      },
      error: (String? message, int? code, AuthResponseModel? data) {
        emit(
          OtpError(error: data?.msg ?? message ?? 'OTP verification failed'),
        );
      },
    );
  }

  Future<void> resendOtp({
    required String email,
    required BuildContext context, // Add context parameter
  }) async {
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    emit(OtpLoadingResend());

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(OtpError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await authRemoteDataSource.resendOtp(email: email);
    result.fold(
      success: (AuthResponseModel response) {
        if (response.status) {
          emit(OtpResendSuccess(message: response.msg));
          startTimer();
        } else {
          emit(OtpError(error: response.msg));
        }
      },
      error: (String? message, int? code, AuthResponseModel? data) {
        emit(OtpError(error: data?.msg ?? message ?? 'Resend OTP failed'));
      },
    );
  }

  void startTimer() {
    _timer?.cancel();
    int seconds = 5 * 60; // 5 minutes
    emit(OtpTimerRunning(seconds: seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds >= 0) {
        emit(OtpTimerRunning(seconds: seconds));
      } else {
        emit(OtpTimerFinished());
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}