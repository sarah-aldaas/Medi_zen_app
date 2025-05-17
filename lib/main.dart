import 'dart:convert';
import 'dart:ui';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/address_cubit/address_cubit.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import 'package:medizen_app/features/profile/presentaiton/pages/edit_profile_screen.dart';
import 'package:oktoast/oktoast.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'base/blocs/localization_bloc/localization_bloc.dart';
import 'base/constant/storage_key.dart';
import 'base/go_router/go_router.dart';
import 'base/services/di/injection_container_common.dart';
import 'base/services/di/injection_container_gen.dart';
import 'base/services/localization/app_localization_service.dart';
import 'base/services/storage/storage_service.dart';
import 'base/theme/theme.dart';
import 'features/home_page/services/pages/cubits/service_cubit/service_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await bootstrapApplication();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  // ShareApps.init(
  //     appId: '15539901308027672219',
  //     // (AppId from)royalty.shareapps.net
  //     secreteKey: '5ca001f255007786922623',
  //     // (secreteKey from)royalty.shareapps.net
  //     email: 'ayhamalrefay@gmail.com',
  //     //(Email Address which registered in )royalty.shareapps.net (It required for email invitation)
  //     app_name:
  //     'MediZen');
  runApp(const MyApp());
}

String? token = serviceLocator<StorageService>().getFromDisk(StorageKey.token);

Future<void> bootstrapApplication() async {
  await initDI();
  await DependencyInjectionGen.initDI();
}

PatientModel loadingPatientModel() {
  PatientModel myPatientModel;
  final String jsonString = serviceLocator<StorageService>().getFromDisk(
    StorageKey.patientModel,
  );
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  myPatientModel = PatientModel.fromJson(jsonMap);
  return myPatientModel;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      duration: const Duration(milliseconds: 500),
      builder:
          (_, theme) => ResponsiveBreakpoints.builder(
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 960, name: TABLET),
              const Breakpoint(start: 961, end: double.infinity, name: DESKTOP),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LocalizationBloc>(
                  create: (context) => serviceLocator<LocalizationBloc>(),
                  lazy: false,
                ),
                BlocProvider<ProfileCubit>(
                  create: (context) => serviceLocator<ProfileCubit>(),
                  lazy: false,
                ),
                BlocProvider<CodeTypesCubit>(
                  create: (context) => serviceLocator<CodeTypesCubit>(),
                  lazy: false,
                ),
                BlocProvider<ServiceCubit>(
                  create: (context) => serviceLocator<ServiceCubit>(),
                  lazy: false,
                ),
                BlocProvider<ClinicCubit>(
                  create: (context) => serviceLocator<ClinicCubit>(),
                  lazy: false,
                ),
                BlocProvider<TelecomCubit>(
                  create: (context) => serviceLocator<TelecomCubit>(),
                  lazy: false,
                ),
                BlocProvider<AddressCubit>(
                  create: (context) => serviceLocator<AddressCubit>(),
                  lazy: false,
                ),
                BlocProvider<EditProfileFormCubit>(
                  create:
                      (context) => EditProfileFormCubit(
                        serviceLocator<CodeTypesCubit>(),
                      ),
                  lazy: false,
                ),
              ],
              child: BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return SafeArea(
                    child: OKToast(
                      child: MaterialApp.router(
                        routerConfig: goRouter(),
                        theme: theme,
                        debugShowCheckedModeBanner: false,
                        title: 'MediZen Mobile',
                        locale: state.locale,
                        supportedLocales: AppLocalizations.supportedLocales,
                        localizationsDelegates: [
                          AppLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
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
