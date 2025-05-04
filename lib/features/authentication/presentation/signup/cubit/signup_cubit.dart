import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../data/datasource/auth_remote_data_source.dart';
import '../../../data/models/register_request_model.dart';

class SignupState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  SignupState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  factory SignupState.initial() => SignupState();
  factory SignupState.loading() => SignupState(isLoading: true);
  factory SignupState.success(String message) => SignupState(successMessage: message);
  factory SignupState.error(String error) => SignupState(errorMessage: error);
}

class SignupCubit extends Cubit<SignupState> {
  final AuthRemoteDataSource authRemoteDataSource;

  SignupCubit({required this.authRemoteDataSource}) : super(SignupState.initial());

  // Helper method to parse error messages from API response
  String _parseErrorMessage(dynamic msg) {
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

  Future<void> signup({required RegisterRequestModel registerRequestModel}) async {
    emit(SignupState.loading());

    try {
      final result = await authRemoteDataSource.signup(registerRequestModel: registerRequestModel);
      result.fold(
        success: (AuthResponseModel response) {
          if (response.status) {
            emit(SignupState.success(response.msg));
          } else {
            emit(SignupState.error(_parseErrorMessage(response.msg)));
          }
        },
        error: (String? message, int? code, AuthResponseModel? data) {
          emit(SignupState.error(data != null ? _parseErrorMessage(data.msg) : message ?? 'Signup failed'));
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