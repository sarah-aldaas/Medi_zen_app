import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/features/articles/presentation/cubit/article_cubit/article_cubit.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medizen_app/features/invoice/presentation/cubit/invoice_cubit/invoice_cubit.dart';
import 'package:medizen_app/features/medical_records/allergy/data/data_source/allergy_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medizen_app/features/medical_records/conditions/data/data_source/condition_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import 'package:medizen_app/features/medical_records/encounter/data/data_source/encounter_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medizen_app/features/medical_records/imaging_study/data/data_source/imaging_study_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/imaging_study/presentation/cubit/imaging_study_cubit/imaging_study_cubit.dart';
import 'package:medizen_app/features/medical_records/medication_request/presentation/cubit/medication_request_cubit/medication_request_cubit.dart';
import 'package:medizen_app/features/medical_records/observation/data/data_source/observation_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/observation/presentation/cubit/observation_cubit/observation_cubit.dart';
import 'package:medizen_app/features/medical_records/reaction/data/data_source/reaction_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medizen_app/features/medical_records/series/data/data_source/series_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/series/presentation/cubit/series_cubit/series_cubit.dart';
import 'package:medizen_app/features/medical_records/service_request/data/data_source/service_request_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/cubit/service_request_cubit/service_request_cubit.dart';
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
import 'features/appointment/pages/cubit/appointment_cubit/appointment_cubit.dart';
import 'features/medical_records/medication/presentation/cubit/medication_cubit/medication_cubit.dart';
import 'features/services/pages/cubits/service_cubit/service_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await bootstrapApplication();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

  runApp(const MyApp());
}

String? token   = serviceLocator<StorageService>().getFromDisk(StorageKey.token);

Future<void> bootstrapApplication() async {
  await initDI();
  await DependencyInjectionGen.initDI();
}

PatientModel loadingPatientModel() {
  PatientModel myPatientModel;
  final String jsonString = serviceLocator<StorageService>().getFromDisk(StorageKey.patientModel);
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  myPatientModel = PatientModel.fromJson(jsonMap);
  if (myPatientModel.fName == null) {
    serviceLocator<StorageService>().removeFromDisk(StorageKey.token);
    token = null;
  }
  return myPatientModel;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPlatformDark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
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
                BlocProvider<LocalizationBloc>(create: (context) => serviceLocator<LocalizationBloc>(), lazy: false),
                BlocProvider<ProfileCubit>(create: (context) => serviceLocator<ProfileCubit>(), lazy: false),
                BlocProvider<CodeTypesCubit>(create: (context) => serviceLocator<CodeTypesCubit>(), lazy: false),
                BlocProvider<ServiceCubit>(create: (context) => serviceLocator<ServiceCubit>(), lazy: false),
                BlocProvider<ClinicCubit>(create: (context) => serviceLocator<ClinicCubit>(), lazy: false),
                BlocProvider<TelecomCubit>(create: (context) => serviceLocator<TelecomCubit>(), lazy: false),
                BlocProvider<AddressCubit>(create: (context) => serviceLocator<AddressCubit>(), lazy: false),
                BlocProvider<AppointmentCubit>(create: (context) => serviceLocator<AppointmentCubit>(), lazy: false),
                BlocProvider<EditProfileFormCubit>(create: (context) => EditProfileFormCubit(serviceLocator<CodeTypesCubit>()), lazy: false),
                BlocProvider<AllergyCubit>(
                  create: (context) => AllergyCubit(remoteDataSource: serviceLocator<AllergyRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<ReactionCubit>(
                  create: (context) => ReactionCubit(remoteDataSource: serviceLocator<ReactionRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<EncounterCubit>(
                  create: (context) => EncounterCubit(remoteDataSource: serviceLocator<EncounterRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<ServiceRequestCubit>(
                  create: (context) => ServiceRequestCubit(remoteDataSource: serviceLocator<ServiceRequestRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<SeriesCubit>(
                  create: (context) => SeriesCubit(remoteDataSource: serviceLocator<SeriesRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<ObservationCubit>(
                  create: (context) => ObservationCubit(remoteDataSource: serviceLocator<ObservationRemoteDataSource>(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<ImagingStudyCubit>(
                  create:
                      (context) => ImagingStudyCubit(
                        imagingStudyDataSource: serviceLocator<ImagingStudyRemoteDataSource>(),
                        networkInfo: serviceLocator(),
                        seriesDataSource: serviceLocator<SeriesRemoteDataSource>(),
                      ),
                  lazy: false,
                ),

                BlocProvider<ConditionsCubit>(
                  create: (context) => ConditionsCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<MedicationRequestCubit>(
                  create: (context) => MedicationRequestCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<MedicationCubit>(
                  create: (context) => MedicationCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<ArticleCubit>(
                  create: (context) => ArticleCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
                BlocProvider<InvoiceCubit>(
                  create: (context) => InvoiceCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()),
                  lazy: false,
                ),
              ],
              child: BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return OKToast(
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
                  );
                },
              ),
            ),
          ),
    );
  }
}
//
//
// import 'dart:convert';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
//
// import 'FCMService.dart';
// import 'base/constant/storage_key.dart';
// import 'base/services/di/injection_container_common.dart';
// import 'base/services/di/injection_container_common.dart' as DependencyInjectionGen;
// import 'base/services/storage/storage_service.dart';
// import 'features/authentication/data/models/patient_model.dart';

// // Background message handler (must be top-level)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase
//   await Firebase.initializeApp();
//
//   // Set background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // Initialize FCM
//   final fcmService = FCMService();
//   await fcmService.initFCM();
//
//   runApp(const MyApp());
// }
//
//
// String? token   = serviceLocator<StorageService>().getFromDisk(StorageKey.token);
//
// Future<void> bootstrapApplication() async {
//   await initDI();
//   await DependencyInjectionGen.initDI();
// }
//
// PatientModel loadingPatientModel() {
//   PatientModel myPatientModel;
//   final String jsonString = serviceLocator<StorageService>().getFromDisk(StorageKey.patientModel);
//   final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
//   myPatientModel = PatientModel.fromJson(jsonMap);
//   if (myPatientModel.fName == null) {
//     serviceLocator<StorageService>().removeFromDisk(StorageKey.token);
//     token = null;
//   }
//   return myPatientModel;
// }
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FCM Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const NotificationScreen(),
//     );
//   }
// }
//
// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   String? _token;
//   String? _lastMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _getToken();
//     _setupInteractedMessage();
//   }
//
//   Future<void> _getToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     setState(() {
//       _token = token;
//     });
//     print('Current Token: $token');
//   }
//
//   Future<void> _setupInteractedMessage() async {
//     // Handle notification when app is opened from terminated state
//     RemoteMessage? initialMessage =
//     await FirebaseMessaging.instance.getInitialMessage();
//
//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }
//
//     // Handle notification when app is in background
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//   }
//
//   void _handleMessage(RemoteMessage message) {
//     setState(() {
//       _lastMessage = message.notification?.title ?? 'No title';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('FCM Example')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('FCM Token: ${_token ?? 'Loading...'}'),
//             const SizedBox(height: 20),
//             Text('Last Notification: ${_lastMessage ?? 'None'}'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// // Global FCM Service instance
// final FCMService fcmService = FCMService();
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('🌌 App in background - message received');
//
//   // Create an instance of your FCMService
//   final fcmService = FCMService();
//   await fcmService.showNotification(message);
// }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase
//   await Firebase.initializeApp();
//
//   // Set background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // Initialize FCM
//   await fcmService.init();
//
//   runApp(const MyApp());
// }
//
// String? token   = serviceLocator<StorageService>().getFromDisk(StorageKey.token);
//
// Future<void> bootstrapApplication() async {
//   await initDI();
//   await DependencyInjectionGen.initDI();
// }
//
// PatientModel loadingPatientModel() {
//   PatientModel myPatientModel;
//   final String jsonString = serviceLocator<StorageService>().getFromDisk(StorageKey.patientModel);
//   final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
//   myPatientModel = PatientModel.fromJson(jsonMap);
//   if (myPatientModel.fName == null) {
//     serviceLocator<StorageService>().removeFromDisk(StorageKey.token);
//     token = null;
//   }
//   return myPatientModel;
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String? _token;
//   String? _lastMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//     _setupMessageInteractions();
//   }
//
//   Future<void> _loadToken() async {
//     _token = await fcmService.getStoredToken();
//     setState(() {});
//   }
//
//   void _setupMessageInteractions() {
//     // When app is opened from terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         setState(() {
//           _lastMessage = message.notification?.title ?? 'No title';
//         });
//       }
//     });
//
//     // When app is in background
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       setState(() {
//         _lastMessage = message.notification?.title ?? 'No title';
//       });
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MediZen FCM',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: const Text('FCM Demo')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('FCM Token: ${_token ?? 'Loading...'}'),
//               const SizedBox(height: 20),
//               Text('Last Notification: ${_lastMessage ?? 'None'}'),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   final token = await FirebaseMessaging.instance.getToken();
//                   setState(() {
//                     _token = token;
//                   });
//                 },
//                 child: const Text('Refresh Token'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


