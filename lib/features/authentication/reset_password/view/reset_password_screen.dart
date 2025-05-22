import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';
import '../../change_password/view/change_password_page.dart';
import '../../forget_password/view/forget_password.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  List<String> _otp = List.generate(6, (index) => '');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("resetPassword.title".tr(context), style: AppStyles.appBarTitle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "resetPassword.checkEmail".tr(context),
                    textAlign: TextAlign.center,
                    style: AppStyles.heading,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "resetPassword.instruction".tr(context),
                    style: AppStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                          (index) => Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _otp[index] = value;
                                if (index < 5 && value.isNotEmpty) {
                                  FocusScope.of(context).nextFocus();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ),
                        );
                      } else if (state is ResetPasswordFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error ?? "resetPassword.errors.default".tr(context))),
                        );
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ResetPasswordLoading
                            ? null
                            : () {
                          context.read<ResetPasswordCubit>().resetPassword(_otp.join());
                        },
                        child: state is ResetPasswordLoading
                            ? LoadingButton(isWhite: true,)
                            : Text(
                          "resetPassword.buttons.reset".tr(context),
                          style: AppStyles.bodyText.copyWith(color: AppColors.whiteColor),
                        ),
                        style: AppStyles.primaryButtonStyle,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Handle resend code
                    },
                    child: Text(
                      "resetPassword.buttons.resendCode".tr(context),
                      style: AppStyles.bodyText.copyWith(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}