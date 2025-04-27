import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medizen_mobile/base/extensions/localization_extensions.dart';
import 'package:medizen_mobile/base/extensions/media_query_extension.dart';

import '../../../base/theme/app_color.dart';
import '../../appointment/pages/appointments.dart';
import '../../medical_record/Medical_Record.dart';
import '../../profile/profile.dart';
import 'home_page_body.dart';

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
      // HomeScreen1(),
      MyAppointmentPage(),
      MedicalRecordPage(),
      ProfilePage(),
    ];

    return ThemeSwitchingArea(
      child: SafeArea(
        child: Scaffold(
          body: _widgetOptions.elementAt(
            _selectedIndex,
          ), // Remove the Center widget
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
                    // tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.grey,
                    tabs: [
                      GButton(
                        icon: Icons.home_outlined,

                        // iconSize: _selectedIndex == 0 ? 30 : 24, // Larger if selected
                        text: 'Home'.tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.date_range_outlined,
                        // iconSize: _selectedIndex == 1 ? 30 : 24, // Larger if selected
                        text: 'Appointment'.tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.medical_information_outlined,
                        // iconSize: _selectedIndex == 2 ? 30 : 24, // Larger if selected
                        text: 'Medical record'.tr(context),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GButton(
                        icon: Icons.person_outline,
                        // iconSize: _selectedIndex == 3 ? 30 : 24, // Larger if selected
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),

                        text: 'Profile'.tr(context),
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
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
