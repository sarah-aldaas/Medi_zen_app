import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/Complaint/view/complaint_list_screen.dart';
import '../../features/articles/pages/articles.dart';
import '../../features/articles/pages/my_book_mark.dart';
import '../../features/authentication/forget_password/view/forget_password.dart';
import '../../features/authentication/login/view/login_screen.dart';
import '../../features/authentication/otp/otp_page.dart';
import '../../features/authentication/signup/view/signup_screen.dart';
import '../../features/clinics/pages/clinics.dart';
import '../../features/doctor/pages/doctor.dart';
import '../../features/help_center/pages/help_center.dart';
import '../../features/home_page/pages/home_page.dart';
import '../../features/home_page/pages/widgets/clinics_page.dart';
import '../../features/notifications/pages/notification_settings.dart';
import '../../features/profile/profile.dart';
import '../../features/settings/change_lang.dart';
import '../../features/settings/change_password.dart';
import '../../features/settings/change_theme.dart';
import '../../features/settings/settings.dart';
import '../../features/start_app/on_boarding/view/on_boarding_screen.dart';
import '../../features/start_app/splash_screen/view/splash_screen.dart';
import '../../features/start_app/welcome/view/welcome_screen.dart';

enum AppRouter {
  login,
  signUp,
  forgetPassword,
  otp,
  onBoarding,
  splashScreen,
  welcomeScreen,
  settings,
  changePassword,
  changeTheme,
  changeLang,
  homePage,
  profile,
  notificationSettings,
  helpCenter,
  articles,
  myBookMark,
  clinics,
  doctors,
  clinic,
  complaint,
}

GoRouter goRouter() {
  return GoRouter(
    initialLocation: "/homePage",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
          GoRoute(
            path: "/register",
            name: AppRouter.signUp.name,
            builder: (BuildContext context, GoRouterState state) {
              return SignupScreen();
            },
          ),
          GoRoute(
            path: "/login",
            name: AppRouter.login.name,
            builder: (BuildContext context, GoRouterState state) {
              return LoginScreen();
            },
          ),
          GoRoute(
            path: "/splashScreen",
            name: AppRouter.splashScreen.name,
            builder: (BuildContext context, GoRouterState state) {
              return SplashScreen();
            },
          ),
          GoRoute(
            path: "/onboarding",
            name: AppRouter.onBoarding.name,
            builder: (BuildContext context, GoRouterState state) {
              return OnBoardingScreen();
            },
          ),
          GoRoute(
            path: "/welcome",
            name: AppRouter.welcomeScreen.name,
            builder: (BuildContext context, GoRouterState state) {
              return WelcomeScreen();
            },
          ),
          // GoRoute(
          //   path: "/settings",
          //   name: AppRouter.settings.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return Settings();
          //   },
          // ),
          // GoRoute(
          //   path: "/changeTheme",
          //   name: AppRouter.changeTheme.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ChangeTheme();
          //   },
          // ),
          // GoRoute(
          //   path: "/changeLang",
          //   name: AppRouter.changeLang.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ChangeLang();
          //   },
          // ),
          // GoRoute(
          //   path: "/changePassword",
          //   name: AppRouter.changePassword.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ChangePassword();
          //   },
          // ),
          GoRoute(
            path: "/homePage",
            name: AppRouter.homePage.name,
            builder: (BuildContext context, GoRouterState state) {
              return HomePage();
            },
          ),
          GoRoute(
            path: "/profile",
            name: AppRouter.profile.name,
            builder: (BuildContext context, GoRouterState state) {
              return ProfilePage();
            },
          ),
          GoRoute(
            path: "/forgetPassword",
            name: AppRouter.forgetPassword.name,
            builder: (BuildContext context, GoRouterState state) {
              return ForgotPasswordScreen();
            },
          ),
          GoRoute(
            path: "/otpPage",
            name: AppRouter.otp.name,
            builder: (BuildContext context, GoRouterState state) {
              return OtpPage();
            },
          ),
          GoRoute(
            path: "/notificationSettings",
            name: AppRouter.notificationSettings.name,
            builder: (BuildContext context, GoRouterState state) {
              return NotificationSettingsPage();
            },
          ),
          GoRoute(
            path: "/helpCenter",
            name: AppRouter.helpCenter.name,
            builder: (BuildContext context, GoRouterState state) {
              return HelpCenterPage();
            },
          ),
          GoRoute(
            path: "/articles",
            name: AppRouter.articles.name,
            builder: (BuildContext context, GoRouterState state) {
              return Articles();
            },
          ),
          GoRoute(
            path: "/clinics",
            name: AppRouter.clinics.name,
            builder: (BuildContext context, GoRouterState state) {
              return Clinics();
            },
          ),
          GoRoute(
            path: "/doctors",
            name: AppRouter.doctors.name,
            builder: (BuildContext context, GoRouterState state) {
              return DoctorsPage();
            },
          ),
          GoRoute(
            path: "/myBookMark",
            name: AppRouter.myBookMark.name,
            builder: (BuildContext context, GoRouterState state) {
              return MyBookmarkPage();
            },
          ),
          GoRoute(
            path: "/myClinics",
            name: AppRouter.clinic.name,
            builder: (BuildContext context, GoRouterState state) {
              return ClinicsPage();
            },
          ),
          GoRoute(
            path: "/complaint",
            name: AppRouter.complaint.name,
            builder: (BuildContext context, GoRouterState state) {
              return ComplaintListScreen();
            },
          ),
        ],
      ),
    ],
  );
}
