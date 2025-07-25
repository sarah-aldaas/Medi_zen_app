import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/features/authentication/presentation/signup/view/widget/signup_form.dart';

import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/theme/app_color.dart';
import '../cubit/signup_cubit.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
// <<<<<<< HEAD
//               (context) => SignupCubit(authRemoteDataSource: serviceLocator(),),
//         ),
//         BlocProvider(
//           create:
//               (context) => CodeTypesCubit(remoteDataSource: serviceLocator()),
// =======
              (context) => SignupCubit(
                authRemoteDataSource: serviceLocator(),

              ),
        ),
        BlocProvider(
          create:
              (context) => CodeTypesCubit(
                remoteDataSource: serviceLocator(),
              ),
// >>>>>>> c804e45c3224c511626af6e9cbcb1dd2e908ee6d
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.replaceNamed(AppRouter.welcomeScreen.name);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "sign_up_page.sign_up".tr(context),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 60),
                SignupForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
