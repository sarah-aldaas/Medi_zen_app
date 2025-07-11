import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/storage_key.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/storage/storage_service.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:meta/meta.dart';
import '../../../../../FCM_manager.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  LogoutCubit({
    required this.authRemoteDataSource,
    required this.networkInfo,
  }) : super(LogoutInitial());

  void sendResetLink(int allDevices, BuildContext context) async {

    if (allDevices == 1) {
      emit(LogoutLoadingAllDevices());
    } else {
      emit(LogoutLoadingOnlyThisDevice());
    }
    // final isConnected = await networkInfo.isConnected;
    //
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(LogoutError(error: 'No internet connection'));
    //   return;
    // }


    try {
      await serviceLocator<FCMManager>().deleteToken(context);
      final result = await authRemoteDataSource.logout(allDevices: allDevices);

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          serviceLocator<StorageService>().removeFromDisk(StorageKey.token);
          serviceLocator<StorageService>().removeFromDisk(
            StorageKey.patientModel,
          );
          emit(LogoutSuccess(message: result.data.msg.toString()));
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
          emit(LogoutError(error: errorMessage));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        emit(LogoutError(error: result.message ?? 'An error occurred'));
      }
    } on ServerException catch (e) {
      emit(LogoutError(error: e.message));
    } catch (e) {
      emit(LogoutError(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}