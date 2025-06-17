import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/storage/storage_service.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../main.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  LoginCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(LoginInitial());

  void login(String email, String password, BuildContext context) async {
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(LoginError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    emit(LoginLoading());
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(LoginError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }
    try {
      final result = await authRemoteDataSource.login(
        email: email,
        password: password,
      );

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          final loginData = result.data.loginData;
          if (loginData != null) {
            token = loginData.token;
            serviceLocator<StorageService>().saveToDisk(
              StorageKey.token,
              token,
            );
            serviceLocator<StorageService>().savePatient(
              StorageKey.patientModel,
              loginData.patient,
            );
            emit(LoginSuccess(message: result.data.msg));
          } else {
            emit(LoginError(error: _parseErrorMessage(result.data.msg)));
          }
        } else {
          emit(LoginError(error: _parseErrorMessage(result.data.msg)));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        emit(LoginError(error: result.message ?? 'An error occurred'));
      }
    } on ServerException catch (e) {
      emit(LoginError(error: e.message));
    } catch (e) {
      emit(LoginError(error: 'Unexpected error: ${e.toString()}'));
    }
  }

  String _parseErrorMessage(dynamic msg) {
    String errorMessage = '';
    if (msg is Map<String, dynamic>) {
      msg.forEach((key, value) {
        if (value is List) {
          errorMessage += '${key.capitalize()}: ${value.join(', ')}\n';
        } else {
          errorMessage += '${key.capitalize()}: $value\n';
        }
      });
    } else if (msg is String) {
      errorMessage = msg;
    } else {
      errorMessage = 'Unknown error';
    }
    return errorMessage.trim();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}