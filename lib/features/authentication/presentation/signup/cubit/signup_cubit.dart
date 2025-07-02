import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';
import '../../../data/models/register_request_model.dart';

class SignupState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  SignupState({this.isLoading = false, this.successMessage, this.errorMessage});

  factory SignupState.initial() => SignupState();
  factory SignupState.loading() => SignupState(isLoading: true);
  factory SignupState.success(String message) =>
      SignupState(successMessage: message);
  factory SignupState.error(String error) => SignupState(errorMessage: error);
}

class SignupCubit extends Cubit<SignupState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  SignupCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(SignupState.initial());

  String parseErrorMessage(dynamic msg) {
    if (msg is Map<String, dynamic>) {
      final errors = <String>[];
      msg.forEach((key, value) {
        if (value is List) {
          errors.add(value.join(', '));
        } else {
          errors.add(value.toString());
        }
      });
      return errors.join(', ');
    } else if (msg is String) {
      return msg;
    }
    return 'Unknown error';
  }

  Future<void> signup({
    required RegisterRequestModel registerRequestModel,
    required BuildContext context, // Add context parameter
  }) async {
    emit(SignupState.loading());

    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(SignupState.error('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    try {
      final result = await authRemoteDataSource.signup(
        registerRequestModel: registerRequestModel,
      );
      result.fold(
        success: (AuthResponseModel response) {
          if (response.status) {
            emit(SignupState.success(response.msg));
          } else {
            emit(SignupState.error(parseErrorMessage(response.msg)));
          }
        },
        error: (String? message, int? code, AuthResponseModel? data) {
          emit(
            SignupState.error(
              data != null
                  ? parseErrorMessage(data.msg)
                  : message ?? 'Signup failed',
            ),
          );
        },
      );
    } catch (e) {
      if (e is ServerException) {
        emit(SignupState.error(e.message));
      } else {
        emit(SignupState.error('Unexpected error: ${e.toString()}'));
      }
    }
  }
}