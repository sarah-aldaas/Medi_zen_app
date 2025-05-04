import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/authentication/data/models/register_request_model.dart';
import '../../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../../base/data/models/code_type_model.dart';
import '../../cubit/signup_cubit.dart';
import '../../cubit/signup_form_cubit.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  late final SignupFormCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SignupFormCubit(context.read<CodeTypesCubit>());
    _cubit.loadCodes();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
      ],
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ShowToast.showToastSuccess(message: state.successMessage!);
            context.pushNamed(AppRouter.otpVerification.name, extra: {'email': _cubit.state.formData['email']});
          } else if (state.errorMessage != null) {
            ShowToast.showToastError(message: state.errorMessage!);
          }
        },
        builder: (context, signupState) {
          return BlocBuilder<SignupFormCubit, SignupFormState>(
            builder: (context, state) {
              if (state.isLoadingCodes) {
                return Center(child: LoadingPage());
              }

              return Form(
                key: const Key('signupForm'),
                child: Column(
                  children: [
                    _buildTextField('firstName', 'sign_up_page.first_name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField('lastName', 'sign_up_page.last_name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField('email', 'sign_up_page.email', Icons.email),
                    const SizedBox(height: 20),
                    _buildPasswordField('password', 'sign_up_page.password'),
                    const SizedBox(height: 20),
                    _buildPasswordField('confirmPassword', 'sign_up_page.confirm_password'),
                    const SizedBox(height: 20),
                    _buildDropdown('genderId', 'sign_up_page.gender', state.genderCodes, (value) => _cubit.updateGenderId(value)),
                    const SizedBox(height: 20),
                    _buildDropdown('maritalStatusId', 'sign_up_page.marital_status', state.maritalStatusCodes, (value) => _cubit.updateMaritalStatusId(value)),
                    const SizedBox(height: 40),
                    _buildSignUpButton(context, signupState),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(String key, String hintKey, IconData icon) {
    return TextFormField(
      onChanged: (value) => _cubit.updateFormData(key, value),
      initialValue: _cubit.state.formData[key],
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        hintText: hintKey.tr(context),
        prefixIcon: Icon(icon, color: const Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'sign_up_page.validation.${key}_required'.tr(context);
        }
        if (key == 'email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'sign_up_page.validation.email_invalid'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(String key, String hintKey) {
    return BlocBuilder<SignupFormCubit, SignupFormState>(
      builder: (context, state) {
        final obscureText = key == 'password' ? state.obscurePassword : state.obscureConfirmPassword;
        return TextFormField(
          onChanged: (value) => _cubit.updateFormData(key, value),
          initialValue: state.formData[key],
          obscureText: obscureText,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            hintText: hintKey.tr(context),
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF47BD93)),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                if (key == 'password') {
                  _cubit.togglePasswordVisibility();
                } else {
                  _cubit.toggleConfirmPasswordVisibility();
                }
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'sign_up_page.validation.${key}_required'.tr(context);
            }
            if (key == 'password' && value.length < 6) {
              return 'sign_up_page.validation.password_length'.tr(context);
            }
            if (key == 'confirmPassword' && value != state.formData['password']) {
              return 'sign_up_page.validation.passwords_not_match'.tr(context);
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDropdown(String key, String hintKey, List<CodeModel> codes, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: key == 'genderId' ? _cubit.state.genderId : _cubit.state.maritalStatusId,
      decoration: InputDecoration(
        hintText: hintKey.tr(context),
        prefixIcon: Icon(key == 'genderId' ? Icons.male : Icons.people, color: const Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      items: codes.map((code) {
        return DropdownMenuItem<String>(
          value: code.id.toString(),
          child: key == 'genderId'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  code.display.toLowerCase() == 'male' ? Icons.male : Icons.female,
                  color: code.display.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
                ),
              ),
              Text(code.display),
            ],
          )
              : Text(code.display),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'sign_up_page.validation.${key.split('Id')[0]}_required'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton(BuildContext context, SignupState signupState) {
    return ElevatedButton(
      onPressed: _cubit.isFormValid() ? () => _cubit.submitForm(context) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: context.width / 3, vertical: 15),
      ),
      child: signupState.isLoading
          ?  LoadingButton(isWhite: true)
          : Text("sign_up_page.sign_up".tr(context), style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("sign_up_page.already_have_account".tr(context)),
        TextButton(
          onPressed: () {
            context.pushNamed(AppRouter.login.name);
          },
          child: Text("sign_up_page.login".tr(context), style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
      ],
    );
  }
}