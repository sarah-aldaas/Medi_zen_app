import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/features/appointment/data/datasource/appointment_remote_datasource.dart';
import 'package:medizen_app/features/appointment/pages/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:medizen_app/features/articles/presentation/cubit/article_cubit/article_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/forget_password/cubit/forgot_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/forget_password/cubit/otp_verify_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/reset_password/cubit/reset_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/signup/cubit/signup_cubit.dart';
import 'package:medizen_app/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medizen_app/features/complains/data/data_source/complain_remote_datasource.dart';
import 'package:medizen_app/features/complains/presentation/cubit/complain_cubit/complain_cubit.dart';
import 'package:medizen_app/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:medizen_app/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medizen_app/features/invoice/presentation/cubit/invoice_cubit/invoice_cubit.dart';
import 'package:medizen_app/features/medical_records/allergy/data/data_source/allergy_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/data_source/diagnostic_report_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/presentation/cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';
import 'package:medizen_app/features/medical_records/encounter/data/data_source/encounter_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medizen_app/features/medical_records/imaging_study/data/data_source/imaging_study_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/imaging_study/presentation/cubit/imaging_study_cubit/imaging_study_cubit.dart';
import 'package:medizen_app/features/medical_records/observation/data/data_source/observation_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/observation/presentation/cubit/observation_cubit/observation_cubit.dart';
import 'package:medizen_app/features/medical_records/reaction/data/data_source/reaction_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medizen_app/features/medical_records/series/data/data_source/series_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/series/presentation/cubit/series_cubit/series_cubit.dart';
import 'package:medizen_app/features/medical_records/service_request/data/data_source/service_request_remote_data_source.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/cubit/service_request_cubit/service_request_cubit.dart';
import 'package:medizen_app/features/notifications/data/data_source/notification_remote_datasource.dart';
import 'package:medizen_app/features/notifications/presentation/cubit/notification_cubit/notification_cubit.dart';
import 'package:medizen_app/features/organization/data/data_source/organization_remote_datasource.dart';
import 'package:medizen_app/features/organization/presentation/cubit/organization_cubit/organization_cubit.dart';
import 'package:medizen_app/features/profile/data/data_sources/address_remote_data_sources.dart';
import 'package:medizen_app/features/profile/data/data_sources/telecom_remote_data_sources.dart';
import 'package:medizen_app/features/profile/data/data_sources/profile_remote_data_sources.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/address_cubit/address_cubit.dart';
import 'package:medizen_app/features/services/pages/cubits/service_cubit/service_cubit.dart';
import '../../../FCM_manager.dart';
import '../../../features/articles/data/data_sources/articles_remote_data_sources.dart';
import '../../../features/authentication/data/datasource/auth_remote_data_source.dart';
import '../../../features/authentication/presentation/login/cubit/login_cubit.dart';
import '../../../features/authentication/presentation/otp/cubit/otp_cubit.dart';
import '../../../features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import '../../../features/invoice/data/data_source/invoice_remote_data_sources.dart';
import '../../../features/medical_records/conditions/data/data_source/condition_remote_data_source.dart';
import '../../../features/medical_records/conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import '../../../features/medical_records/medication/data/data_source/medication_remote_data_source.dart';
import '../../../features/medical_records/medication/presentation/cubit/medication_cubit/medication_cubit.dart';
import '../../../features/medical_records/medication_request/data/data_source/medication_request_remote_data_source.dart';
import '../../../features/medical_records/medication_request/presentation/cubit/medication_request_cubit/medication_request_cubit.dart';
import '../../../features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';
import '../../../features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import '../../../features/services/data/datasources/services_remote_datasoources.dart';
import '../../blocs/localization_bloc/localization_bloc.dart';
import '../../data/data_sources/remote_data_sources.dart';
import '../logger/logging.dart';
import '../network/network_info.dart';
import 'injection_container_cache.dart';
import 'network_client_injection_container.dart';

final serviceLocator = GetIt.I;

Future<void> initDI() async {
  await _initService();
  await _initDataSource();
  await _initBloc();
}

Future<void> _initService() async {
  serviceLocator.registerSingleton<LogService>(LogService(log: Logger()));
  await CacheDependencyInjection.initDi();
  serviceLocator.registerSingleton<NetworkInfo>(NetworkInfoImplementation(connectivity: Connectivity()));
  serviceLocator.registerSingleton<LocalizationBloc>(LocalizationBloc());
  await NetworkClientDependencyInjection.initDi();
}

Future<void> _initDataSource() async {
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(networkClient: serviceLocator()));

  serviceLocator.registerLazySingleton<RemoteDataSourcePublic>(() => RemoteDataSourcePublicImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<TelecomRemoteDataSource>(() => TelecomRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<AddressRemoteDataSource>(() => AddressRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<AppointmentRemoteDataSource>(() => AppointmentRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ClinicRemoteDataSource>(() => ClinicRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<DoctorRemoteDataSource>(() => DoctorRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ServicesRemoteDataSource>(() => ServicesRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<AllergyRemoteDataSource>(() => AllergyRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<EncounterRemoteDataSource>(() => EncounterRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ReactionRemoteDataSource>(() => ReactionRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ServiceRequestRemoteDataSource>(() => ServiceRequestRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<SeriesRemoteDataSource>(() => SeriesRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ObservationRemoteDataSource>(() => ObservationRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ImagingStudyRemoteDataSource>(() => ImagingStudyRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<MedicationRequestRemoteDataSource>(() => MedicationRequestRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<MedicationRemoteDataSource>(() => MedicationRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ConditionRemoteDataSource>(() => ConditionRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ArticlesRemoteDataSource>(() => ArticlesRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<InvoiceRemoteDataSource>(() => InvoiceRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ComplainRemoteDataSource>(() => ComplainRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<DiagnosticReportRemoteDataSource>(() => DiagnosticReportRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<OrganizationRemoteDataSource>(() => OrganizationRemoteDataSourceImpl(networkClient: serviceLocator()));
}

Future<void> _initBloc() async {
  serviceLocator.registerLazySingleton(() => FCMManager(
    notificationCubit: serviceLocator(),
    storageService: serviceLocator(),
  ));

  serviceLocator.registerFactory<SignupCubit>(() => SignupCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<OtpCubit>(() => OtpCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<OtpVerifyPasswordCubit>(() => OtpVerifyPasswordCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<LoginCubit>(() => LoginCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));

  serviceLocator.registerFactory<LogoutCubit>(() => LogoutCubit(authRemoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<CodeTypesCubit>(() => CodeTypesCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ProfileCubit>(() => ProfileCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<TelecomCubit>(() => TelecomCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AddressCubit>(() => AddressCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AppointmentCubit>(() => AppointmentCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ClinicCubit>(() => ClinicCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ServiceCubit>(() => ServiceCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<DoctorCubit>(() => DoctorCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AllergyCubit>(() => AllergyCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ReactionCubit>(() => ReactionCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<EncounterCubit>(() => EncounterCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ServiceRequestCubit>(() => ServiceRequestCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ObservationCubit>(() => ObservationCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<SeriesCubit>(() => SeriesCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ImagingStudyCubit>(
    () => ImagingStudyCubit(imagingStudyDataSource: serviceLocator(), seriesDataSource: serviceLocator(), networkInfo: serviceLocator()),
  );
  serviceLocator.registerFactory<ConditionsCubit>(() => ConditionsCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<MedicationRequestCubit>(() => MedicationRequestCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<MedicationCubit>(() => MedicationCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<InvoiceCubit>(() => InvoiceCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ArticleCubit>(() => ArticleCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ComplainCubit>(() => ComplainCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<DiagnosticReportCubit>(() => DiagnosticReportCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<NotificationCubit>(() => NotificationCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
  serviceLocator.registerFactory<OrganizationCubit>(() => OrganizationCubit(remoteDataSource: serviceLocator(), networkInfo: serviceLocator()));
}
