import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/clinics/pages/clinic_details_page.dart';
import 'package:medizen_app/features/clinics/pages/clinics_page.dart';
import 'package:medizen_app/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/my_favorite.dart';
import 'package:medizen_app/features/home_page/pages/widgets/search_field.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_doctors.dart';

import '../../../main.dart';
import '../../profile/presentaiton/widgets/avatar_image_widget.dart';
import '../../services/Services.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  ///modify clinic id
  final String clinicId="1";

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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("homePage.specialties.title".tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicsPage()));
                        },
                        child: Text("homePage.specialties.seeAll".tr(context), style: TextStyle(color: Theme.of(context).primaryColor)),
                      ),
                    ],
                  ),
                ),
                Gap(10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 15.0,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.local_hospital_outlined, "homePage.specialties.items.general".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.density_medium_outlined, "homePage.specialties.items.dentist".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.remove_red_eye_outlined, "homePage.specialties.items.ophthalmology".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.fastfood_outlined, "homePage.specialties.items.nutrition".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.psychology_outlined, "homePage.specialties.items.neurology".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.child_friendly_outlined, "homePage.specialties.items.pediatrics".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.waves_outlined, "homePage.specialties.items.radiology".tr(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsPage(clinicId: clinicId)));
                        },
                        child: _buildSpecialityItem(Icons.more_horiz, "homePage.specialties.items.more".tr(context)),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                DefinitionWidget(),
                const Gap(10),
                SomeDoctors(),
                const Gap(20),
                SomeArticles(),
                const Gap(20),
                SomeServices(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    PatientModel? myPatientModel = loadingPatientModel();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AvatarImage(imageUrl: myPatientModel.avatar, radius: 20),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [GreetingWidget(), Text("${myPatientModel.fName.toString()} ${myPatientModel.lName.toString()}", style: TextStyle(fontWeight: FontWeight.bold))],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.notifications_outlined),
              const SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.favorite_border, size: 25),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyFavorite()));
                },
              ),
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
        children: [Icon(icon, size: 30, color: Theme.of(context).primaryColor), const SizedBox(height: 4.0), Text(label, style: const TextStyle(fontSize: 12))],
      ),
    );
  }
}
