import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../login/view/login_screen.dart';
import '../../reset_password/view/reset_password_screen.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (context) => ForgotPasswordCubit(),
      child: _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  @override
  State<_ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
          );
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? "forgotPassword.errors.default".tr(context))),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "forgotPassword.title".tr(context),
                  style: AppStyles.titleTextStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 40),
                Text(
                  "forgotPassword.instruction".tr(context),
                  textAlign: TextAlign.center,
                  style: AppStyles.instructionTextStyle,
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "forgotPassword.fields.email".tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    context.read<ForgotPasswordCubit>()
                        .sendResetLink(_emailController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: state is ForgotPasswordLoading
                      ?  LoadingButton(isWhite: true,)
                      : Text(
                    "forgotPassword.buttons.continue".tr(context),
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "forgotPassword.buttons.backToLogin".tr(context),
                    style: AppStyles.linkTextStyle,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}