import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/authentication/data/models/register_request_model.dart';
import 'package:medizen_app/features/authentication/presentation/signup/cubit/signup_cubit.dart';

import '../../../../../base/go_router/go_router.dart';

class SignupFormState {
  final List<CodeModel> genderCodes;
  final List<CodeModel> maritalStatusCodes;
  final String? genderId;
  final String? maritalStatusId;
  final bool isLoadingCodes;
  final Map<String, String> formData;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  SignupFormState({
    this.genderCodes = const [],
    this.maritalStatusCodes = const [],
    this.genderId,
    this.maritalStatusId,
    this.isLoadingCodes = true,
    this.formData = const {
      'firstName': '',
      'lastName': '',
      'email': '',
      'password': '',
      'confirmPassword': '',
    },
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  SignupFormState copyWith({
    List<CodeModel>? genderCodes,
    List<CodeModel>? maritalStatusCodes,
    String? genderId,
    String? maritalStatusId,
    bool? isLoadingCodes,
    Map<String, String>? formData,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return SignupFormState(
      genderCodes: genderCodes ?? this.genderCodes,
      maritalStatusCodes: maritalStatusCodes ?? this.maritalStatusCodes,
      genderId: genderId ?? this.genderId,
      maritalStatusId: maritalStatusId ?? this.maritalStatusId,
      isLoadingCodes: isLoadingCodes ?? this.isLoadingCodes,
      formData: formData ?? this.formData,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
      obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }
}

class SignupFormCubit extends Cubit<SignupFormState> {
  final CodeTypesCubit codeTypesCubit;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  SignupFormCubit({
    required this.codeTypesCubit,
    required this.networkInfo,
  }) : super(SignupFormState());

  Future<void> loadCodes(BuildContext context) async {

    if (state.isLoadingCodes) {
      final results = await Future.wait([
        codeTypesCubit.getGenderCodes(context: context),
        codeTypesCubit.getMaritalStatusCodes(context: context),
      ]);
      final uniqueGenderCodes = <String, CodeModel>{};
      final uniqueMaritalStatusCodes = <String, CodeModel>{};

      for (var code in results[0]) {
        uniqueGenderCodes[code.id.toString()] = code;
      }
      for (var code in results[1]) {
        uniqueMaritalStatusCodes[code.id.toString()] = code;
      }

      emit(
        state.copyWith(
          genderCodes: uniqueGenderCodes.values.toList(),
          maritalStatusCodes: uniqueMaritalStatusCodes.values.toList(),
          isLoadingCodes: false,
          genderId:
          uniqueGenderCodes.isNotEmpty
              ? uniqueGenderCodes.values.first.id.toString()
              : null,
          maritalStatusId:
          uniqueMaritalStatusCodes.isNotEmpty
              ? uniqueMaritalStatusCodes.values.first.id.toString()
              : null,
        ),
      );
    }
    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    //
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(state.copyWith(isLoadingCodes: false));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }
  }

  void updateFormData(String key, String value) {
    final newFormData = Map<String, String>.from(state.formData)..[key] = value;
    emit(state.copyWith(formData: newFormData));
  }

  void updateGenderId(String? value) {
    emit(state.copyWith(genderId: value));
  }

  void updateMaritalStatusId(String? value) {
    emit(state.copyWith(maritalStatusId: value));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }

  void submitForm(BuildContext context) {
    if (isFormValid()) {
      final cubit = context.read<SignupCubit>();
      cubit.signup(
        registerRequestModel: RegisterRequestModel(
          firstName: state.formData['firstName']!,
          lastName: state.formData['lastName']!,
          email: state.formData['email']!,
          password: state.formData['password']!,
          genderId: state.genderId!,
          maritalStatusId: state.maritalStatusId!,
        ),
        context: context, // Pass context to SignupCubit
      );
    }
  }

  bool isFormValid() {
    final data = state.formData;
    return data['firstName']!.isNotEmpty &&
        data['lastName']!.isNotEmpty &&
        data['email']!.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data['email']!) &&
        data['password']!.isNotEmpty &&
        data['password']!.length >= 6 &&
        data['confirmPassword']!.isNotEmpty &&
        data['confirmPassword'] == data['password'] &&
        state.genderId != null &&
        state.maritalStatusId != null;
  }
}