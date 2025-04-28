import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/search_field.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_doctors.dart';
import '../../../base/theme/app_color.dart';

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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "homePage.specialties.title".tr(context),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        "homePage.specialties.seeAll".tr(context),
                        style: TextStyle(color: Theme.of(context).primaryColor),
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
                      _buildSpecialityItem(
                          Icons.local_hospital_outlined,
                          "homePage.specialties.items.general".tr(context)),
                      _buildSpecialityItem(
                          Icons.density_medium_outlined,
                          "homePage.specialties.items.dentist".tr(context)),
                      _buildSpecialityItem(
                          Icons.remove_red_eye_outlined,
                          "homePage.specialties.items.ophthalmology".tr(context)),
                      _buildSpecialityItem(
                          Icons.fastfood_outlined,
                          "homePage.specialties.items.nutrition".tr(context)),
                      _buildSpecialityItem(
                          Icons.psychology_outlined,
                          "homePage.specialties.items.neurology".tr(context)),
                      _buildSpecialityItem(
                          Icons.child_friendly_outlined,
                          "homePage.specialties.items.pediatrics".tr(context)),
                      _buildSpecialityItem(
                          Icons.waves_outlined,
                          "homePage.specialties.items.radiology".tr(context)),
                      _buildSpecialityItem(
                          Icons.more_horiz,
                          "homePage.specialties.items.more".tr(context)),
                    ],
                  ),
                ),
                const Gap(10),
                DefinitionWidget(),
                const Gap(10),
                SomeDoctors(),
                const Gap(20),
                SomeArticles(),
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
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingWidget(),
                  Text(
                      "homePage.header.userName".tr(context),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.notifications_outlined),
              SizedBox(width: 16.0),
              Icon(Icons.favorite_border)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialityItem(IconData icon, String label) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - (2 * 16) - (3 * 20)) / 5,
      child: Column(
        children: [
          Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4.0),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}