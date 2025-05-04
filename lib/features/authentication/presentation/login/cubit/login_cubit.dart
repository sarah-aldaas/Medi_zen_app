
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/storage/storage_service.dart';
import 'package:medizen_app/features/authentication/data/datasource/auth_remote_data_source.dart';
import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../main.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRemoteDataSource authRemoteDataSource;

  LoginCubit({required this.authRemoteDataSource}) : super(LoginInitial());

  void login(String email, String password) async {
    emit(LoginLoading());

    try {
      final result = await authRemoteDataSource.login(email: email, password: password);

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          final loginData = result.data.loginData;
          if (loginData != null) {
            token = loginData.token;
            serviceLocator<StorageService>().saveToDisk(StorageKey.token, token);
            serviceLocator<StorageService>().savePatient(StorageKey.patientModel, loginData.patient);
            emit(LoginSuccess(message: result.data.msg));
          }else{
            String errorMessage = '';
            if (result.data.msg is Map<String, dynamic>) {
              // Handle nested error messages
              (result.data.msg as Map<String, dynamic>).forEach((key, value) {
                if (value is List) {
                  errorMessage += value.join(', '); // Join list of errors
                } else {
                  errorMessage += value.toString();
                }
              });
            } else if (result.data.msg is String) {
              errorMessage = result.data.msg;
            } else {
              errorMessage = 'Unknown error';
            }
            emit(LoginError(error: errorMessage));
          }

        } else {
          emit(LoginError(error:result.data.msg));
        }
      }
    } on ServerException catch (e) {
      emit(LoginError(error:e.message));
    } catch (e) {
      emit(LoginError(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}
