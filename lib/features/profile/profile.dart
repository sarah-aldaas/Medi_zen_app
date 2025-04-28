import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../base/blocs/localization_bloc/localization_bloc.dart';
import '../../base/constant/app_images.dart';
import '../../base/go_router/go_router.dart';
import '../../base/theme/theme.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(AppAssetImages.photoDoctor1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Andrew Ainsley',
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
                title: Text('profilePage.editProfile'.tr(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to edit profile
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('profilePage.notification'.tr(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.pushNamed(AppRouter.notificationSettings.name);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.payment_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('profilePage.payment'.tr(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to payment
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.security_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('profilePage.security'.tr(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to security
                },
              ),
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
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('profilePage.language'.tr(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('profilePage.englishUS'.tr(context)), Icon(Icons.chevron_right)],
                ),
                onTap: () {
                  final bloc = context.read<LocalizationBloc>();
                  if (bloc.isArabic()) {
                    bloc.add(const ChangeLanguageEvent(Locale('en')));
                  } else {
                    bloc.add(const ChangeLanguageEvent(Locale('ar')));
                  }
                },
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
                    onTap: () => switcher.changeTheme(
                      theme: theme.brightness == Brightness.light
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
                onTap: () {
                  // Navigate to help center
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.people_outline,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('profilePage.inviteFriends'.tr(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to invite friends
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('profilePage.logout'.tr(context), style: TextStyle(color: Colors.red)),
                onTap: () {
                  // Handle logout
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
