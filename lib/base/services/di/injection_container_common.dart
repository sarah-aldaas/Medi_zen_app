import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/features/appointment/data/datasource/appointment_remote_datasource.dart';
import 'package:medizen_app/features/appointment/pages/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/forget_password/cubit/forgot_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/forget_password/cubit/otp_verify_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/reset_password/cubit/reset_password_cubit.dart';
import 'package:medizen_app/features/authentication/presentation/signup/cubit/signup_cubit.dart';
import 'package:medizen_app/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medizen_app/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:medizen_app/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medizen_app/features/medical_records/allergy/data/data_source/allergy_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medizen_app/features/medical_records/encounter/data/data_source/encounter_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medizen_app/features/medical_records/reaction/data/data_source/reaction_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medizen_app/features/profile/data/data_sources/address_remote_data_sources.dart';
import 'package:medizen_app/features/profile/data/data_sources/telecom_remote_data_sources.dart';
import 'package:medizen_app/features/profile/data/data_sources/profile_remote_data_sources.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/address_cubit/address_cubit.dart';
import 'package:medizen_app/features/services/pages/cubits/service_cubit/service_cubit.dart';

import '../../../features/authentication/data/datasource/auth_remote_data_source.dart';
import '../../../features/authentication/presentation/login/cubit/login_cubit.dart';
import '../../../features/authentication/presentation/otp/cubit/otp_cubit.dart';
import '../../../features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
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
  serviceLocator.registerSingleton<NetworkInfo>(NetworkInfoImplementation(connectivity:Connectivity() ));
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
}

Future<void> _initBloc() async {
  serviceLocator.registerFactory<SignupCubit>(() => SignupCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<OtpCubit>(() => OtpCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<OtpVerifyPasswordCubit>(() => OtpVerifyPasswordCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<LoginCubit>(() => LoginCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));

  serviceLocator.registerFactory<LogoutCubit>(() => LogoutCubit(authRemoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<CodeTypesCubit>(() => CodeTypesCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ProfileCubit>(() => ProfileCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<TelecomCubit>(() => TelecomCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AddressCubit>(() => AddressCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AppointmentCubit>(() => AppointmentCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ClinicCubit>(() => ClinicCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ServiceCubit>(() => ServiceCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<DoctorCubit>(() => DoctorCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<AllergyCubit>(() => AllergyCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<ReactionCubit>(() => ReactionCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
  serviceLocator.registerFactory<EncounterCubit>(() => EncounterCubit(remoteDataSource: serviceLocator(),networkInfo: serviceLocator()));
}
