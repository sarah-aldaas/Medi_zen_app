import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/widgets/show_toast.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<CodeTypesCubit>()..fetchCodeTypes(context: context),
      child: SafeArea(
        child: Scaffold(
          body: BlocConsumer<CodeTypesCubit, CodeTypesState>(
            listener: (context, state) {
              if (state is CodeTypesError) {
                ShowToast.showToastError(message: state.error);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 60),
                      Text("welcome.title".tr(context), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text("welcome.loading_to_enjoy".tr(context), style: TextStyle(color: Color(0xFF9E9E9E))),
                      Text("welcome.stay_healthy".tr(context), style: TextStyle(color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.login.name);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: context.width / 1.5,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(child: Text("welcome.login".tr(context), style: TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.signUp.name);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: context.width / 1.5,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey)),
                          child: Center(
                            child: Text("welcome.sign_up".tr(context), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
