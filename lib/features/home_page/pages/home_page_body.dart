import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_mobile/base/extensions/localization_extensions.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/clinics_page.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/search_field.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_mobile/features/home_page/pages/widgets/some_doctors.dart';

import '../../doctor/doctor_screen.dart';
import '../../services/Services.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                SearchField(),
                // RowIcons(),
                // Gap(10),
                DefinitionWidget(),
                Gap(10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clinics'.tr(context),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClinicsPage(),
                            ),
                          );
                        },
                        child: Text(
                          'See All'.tr(context),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 15.0,
                    children: [
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Doctorscreen(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.local_hospital_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'General..',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.density_medium_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'Dentist',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                          'Ophthal..',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.fastfood_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'Nutrition..',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.psychology_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'Neurolo..',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.child_friendly_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'Pediatric',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.waves_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'Radiolo..',
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                (2 * 16) -
                                (3 * 20)) /
                            5,
                        child: _buildSpecialityItem(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Doctorscreen(), // تأكد من كتابة الاسم الصحيح للفئة
                                ),
                              );
                            },
                            child: Icon(
                              Icons.more_horiz,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          'More',
                        ),
                      ),
                    ],
                  ),
                ),
                SomeDoctors(),
                // Gap(20),
                // SomeClinics(),
                Gap(30),
                SomeArticles(),
                Gap(30),
                SomeServices(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                // You'll likely use an AssetImage or NetworkImage here
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingWidget(),
                  Text(
                    'Andrew Ainsley',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.notifications_outlined),
              SizedBox(width: 16.0),
              Icon(Icons.favorite_border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialityItem(Widget icon, String label) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 4.0),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
