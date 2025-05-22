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
import 'package:medizen_app/features/home_page/pages/widgets/some_clinics.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_doctors.dart';

import '../../../main.dart';
import '../../profile/presentaiton/widgets/avatar_image_widget.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final String clinicId = "1";

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

                SomeClinics(),
                const Gap(10),
                DefinitionWidget(),
                const Gap(10),
                SomeDoctors(),
                const Gap(20),
                SomeArticles(),
                const Gap(20),
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
                children: [
                  GreetingWidget(),
                  Text("${myPatientModel.fName.toString()} ${myPatientModel.lName.toString()}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
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

}
