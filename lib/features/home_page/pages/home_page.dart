import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/home_page/pages/home_page_body.dart';
import '../../appointment/pages/my_appointments_page.dart';
import '../../medical_record/Medical_Record.dart';
import '../../profile/presentaiton/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomePageBody(),
      MyAppointmentPage(),
      MedicalRecordPage(),
      ProfilePage(),
    ];

    return ThemeSwitchingArea(
      child: SafeArea(
        child: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: context.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                  child: GNav(
                    rippleColor: AppColors.backGroundLogo,
                    hoverColor: Theme.of(context).primaryColor,
                    gap: 8,
                    activeColor: Theme.of(context).primaryColor,
                    iconSize: 24,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: Duration(milliseconds: 400),
                    color: Colors.grey,
                    tabs: [
                      GButton(
                        icon: Icons.home_outlined,
                        text: "home.tabs.home".tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.date_range_outlined,
                        text: "home.tabs.appointment".tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.medical_information_outlined,
                        text: "home.tabs.medicalRecord".tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.person_outline,
                        text: "home.tabs.profile".tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange:
                        (index) => setState(() => _selectedIndex = index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
