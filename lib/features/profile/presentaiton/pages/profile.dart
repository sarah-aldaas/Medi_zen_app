import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/theme/theme.dart';
import 'package:medizen_app/features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'package:medizen_app/features/invoice/presentation/pages/my_appointment_finished_invoice_page.dart';
import 'package:medizen_app/main.dart';

import '../../../../base/blocs/localization_bloc/localization_bloc.dart';
import '../../../../base/constant/app_images.dart';
import '../../../../base/constant/storage_key.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/storage/storage_service.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/some classes/theme_cubit.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../../../authentication/data/models/patient_model.dart';
import '../../../complains/presentation/pages/complain_list_page.dart';
import '../../../medical_records/series/presentation/pages/full_screen_image_viewer.dart';
import '../../../organization/presentation/pages/organization_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? _selectedLogoutOption;

  @override
  Widget build(BuildContext context) {
    PatientModel? myPatientModel =
        loadingPatientModel();

    return BlocProvider(
      create: (context) => GetIt.I<LogoutCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.primaryColor,
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 10,
                child: Image.asset(AppAssetImages.logoGreenPng),
              ),
              const SizedBox(width: 10),
              Text(
                'profilePage.title'.tr(context),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (myPatientModel?.avatar != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FullScreenImageViewer(
                                      imageUrl:
                                          myPatientModel!.avatar.toString(),
                                    ),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: FlexibleImage(
                              imageUrl:
                                  myPatientModel
                                      ?.avatar,
                              assetPath: "assets/images/person.jpg",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        myPatientModel == null
                            ? ""
                            : "${myPatientModel.fName ?? ""} ${myPatientModel.lName ?? ""}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.personalDetails'.tr(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(AppRouter.profileDetails.name);
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.insert_comment_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.complaint'.tr(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplainListPage(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.maps_home_work_sharp,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'organizationDetailsPage.organization'.tr(context),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizationDetailsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('invoicesPage.invoice'.tr(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MyAppointmentFinishedInvoicePage(),
                      ),
                    );
                  },
                ),
                ExpansionTile(
                  leading: Icon(
                    Icons.language,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.language'.tr(context)),
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        TextButton(
                          onPressed: () {
                            final bloc = context.read<LocalizationBloc>();
                            if (bloc.isArabic()) {
                              bloc.add(const ChangeLanguageEvent(Locale('en')));
                            }
                          },
                          child: Text("profilePage.english".tr(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        TextButton(
                          onPressed: () {
                            final bloc = context.read<LocalizationBloc>();
                            if (!bloc.isArabic()) {
                              bloc.add(const ChangeLanguageEvent(Locale('ar')));
                            }
                          },
                          child: Text("profilePage.arabic".tr(context)),
                        ),
                      ],
                    ),
                  ],
                ),

                ThemeSwitcher.withTheme(
                  builder: (context, switcher, theme) {
                    return ListTile(
                      leading: Icon(
                        theme.brightness == Brightness.light
                            ? Icons.brightness_3
                            : Icons.brightness_5,
                        size: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        theme.brightness == Brightness.light
                            ? 'profilePage.darkMode'.tr(context)
                            : 'profilePage.lightMode'.tr(context),
                      ),
                      onTap: () {
                        final newTheme =
                            theme.brightness == Brightness.light
                                ? darkTheme
                                : lightTheme;

                        switcher.changeTheme(theme: newTheme);

                        final isDark = newTheme.brightness == Brightness.dark;
                        context.read<ThemeCubit>().toggleTheme(isDark);
                      },
                    );
                  },
                ),
                BlocConsumer<LogoutCubit, LogoutState>(
                  listener: (context, state) {
                    if (state is LogoutSuccess) {
                      context.goNamed(AppRouter.welcomeScreen.name);
                    } else if (state is LogoutError) {
                      _selectedLogoutOption = null;
                      serviceLocator<StorageService>().removeFromDisk(
                        StorageKey.patientModel,
                      );
                      context.goNamed(AppRouter.welcomeScreen.name);
                    }
                  },
                  builder: (context, state) {
                    return ExpansionTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: Text(
                        'profilePage.logout'.tr(context),
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      children: [
                        RadioListTile<int>(
                          title:
                              state is LogoutLoadingOnlyThisDevice
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'profilePage.logoutThisDevice'.tr(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      LoadingAnimationWidget.hexagonDots(
                                        color: Theme.of(context).primaryColor,
                                        size: 25,
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'profilePage.logoutThisDevice'.tr(context),
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                          value: 0,
                          groupValue: _selectedLogoutOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedLogoutOption = value;
                            });
                            context.read<LogoutCubit>().sendResetLink(
                              0,
                              context,
                            );
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        RadioListTile<int>(
                          title:
                              state is LogoutLoadingAllDevices
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'profilePage.logoutAllDevices'.tr(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      LoadingAnimationWidget.hexagonDots(
                                        color: Theme.of(context).primaryColor,
                                        size: 25,
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'profilePage.logoutAllDevices'.tr(context),
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                          value: 1,
                          groupValue: _selectedLogoutOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedLogoutOption = value;
                            });
                            context.read<LogoutCubit>().sendResetLink(
                              1,
                              context,
                            );
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
