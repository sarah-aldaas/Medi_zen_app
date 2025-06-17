import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/theme/theme.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'package:medizen_app/main.dart';

import '../../../../base/blocs/localization_bloc/localization_bloc.dart';
import '../../../../base/constant/app_images.dart';
import '../../../../base/constant/storage_key.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/storage/storage_service.dart';
import '../../../authentication/data/models/patient_model.dart';
import '../widgets/avatar_image_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? _selectedLogoutOption;

  @override
  Widget build(BuildContext context) {
    PatientModel myPatientModel = loadingPatientModel();
    return BlocProvider(
      create: (context) => GetIt.I<LogoutCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            spacing: 10,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 10,
                child: Image.asset(AppAssetImages.logoGreenPng),
              ),
              Text(
                'profilePage.title'.tr(context),
                style: TextStyle(fontWeight: FontWeight.bold),
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
                      AvatarImage(imageUrl: myPatientModel!.avatar, radius: 50),
                      SizedBox(height: 16),
                      Text(
                        myPatientModel == null
                            ? ""
                            : "${myPatientModel!.fName ?? ""} ${myPatientModel!.lName ?? ""}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.personalDetails'.tr(context)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(AppRouter.profileDetails.name);
                  },
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.notifications_none,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: Text('profilePage.notification'.tr(context)),
                //   trailing: Icon(Icons.chevron_right),
                //   onTap: () {
                //     context.pushNamed(AppRouter.notificationSettings.name);
                //   },
                // ),
                // ListTile(
                //   leading: Icon(
                //     Icons.payment_outlined,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: Text('profilePage.payment'.tr(context)),
                //   trailing: Icon(Icons.chevron_right),
                //   onTap: () {},
                // ),
                // ListTile(
                //   leading: Icon(
                //     Icons.security_outlined,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: Text('profilePage.security'.tr(context)),
                //   trailing: Icon(Icons.chevron_right),
                //   onTap: () {},
                // ),
                ListTile(
                  leading: Icon(
                    Icons.insert_comment_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.complaint'.tr(context)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(AppRouter.complaint.name);
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
                        SizedBox(width: 50,),
                        TextButton(onPressed: (){
                          final bloc = context.read<LocalizationBloc>();
                          if(bloc.isArabic())
                            bloc.add(const ChangeLanguageEvent(Locale('en')));

                        }, child: Text("profilePage.english".tr(context))),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 50,),
                        TextButton(onPressed: (){
                          final bloc = context.read<LocalizationBloc>();
                          if(!bloc.isArabic())
                            bloc.add(const ChangeLanguageEvent(Locale('ar')));
                        }, child: Text("profilePage.arabic".tr(context))),
                      ],
                    ),
                  ],
                ),
                ThemeSwitcher.withTheme(
                  builder: (_, switcher, theme) {
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
                      onTap:
                          () => switcher.changeTheme(
                            theme:
                                theme.brightness == Brightness.light
                                    ? darkTheme
                                    : lightTheme,
                          ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('profilePage.helpCenter'.tr(context)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.people_outline,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: Text('profilePage.inviteFriends'.tr(context)),
                //   trailing: Icon(Icons.chevron_right),
                //   onTap: () {
                //     // ShareApps.sendInvitation(context: context);
                //   },
                // ),
                BlocConsumer<LogoutCubit, LogoutState>(
                  listener: (context, state) {
                    if (state is LogoutSuccess) {
                      // ShowToast.showToastSuccess(message: state.message);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text(state.message)),
                      // );

                      context.goNamed(AppRouter.welcomeScreen.name);
                    } else if (state is LogoutError) {
                      _selectedLogoutOption = null;
                      ShowToast.showToastError(message: state.error);
                      serviceLocator<StorageService>().removeFromDisk(
                        StorageKey.patientModel,
                      );
                      context.goNamed(AppRouter.welcomeScreen.name);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text(state.error)),
                      // );
                    }
                  },
                  builder: (context, state) {
                    return ExpansionTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'profilePage.logout'.tr(context),
                        style: TextStyle(color: Colors.red),
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
                                      SizedBox(width: 10),

                                      LoadingAnimationWidget.hexagonDots(
                                        color: Theme.of(context).primaryColor,
                                        size: 25,
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'profilePage.logoutThisDevice'.tr(context),
                                    style: TextStyle(color: Colors.red),
                                  ),
                          value: 0,
                          groupValue: _selectedLogoutOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedLogoutOption = value;
                            });
                            context.read<LogoutCubit>().sendResetLink(0,context);
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
                                      SizedBox(width: 10),
                                      LoadingAnimationWidget.hexagonDots(
                                        color: Theme.of(context).primaryColor,
                                        size: 25,
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'profilePage.logoutAllDevices'.tr(context),
                                    style: TextStyle(color: Colors.red),
                                  ),
                          value: 1,
                          groupValue: _selectedLogoutOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedLogoutOption = value;
                            });
                            context.read<LogoutCubit>().sendResetLink(1,context);
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
