import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
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
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/all_encounters_page.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/appointment_reactions_page.dart';

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
        body: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              _buildHeader(context),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SomeClinics(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DefinitionWidget(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SomeDoctors(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SomeArticles(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    PatientModel? myPatientModel = loadingPatientModel();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16,top: 20,left: 16,right: 8),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'favorites') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyFavorite()));
                  } else if (value == 'services') {
                    // context.pushNamed(AppRouter.healthCareServicesPage.name);
                    context.pushNamed(AppRouter.allAllergiesPage.name);
                  }
                  else if (value == 'encounter') {
                    // context.pushNamed(AppRouter.healthCareServicesPage.name);
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => AllEncountersPage()));

                  }
                  else if (value == 'reaction') {
                    // context.pushNamed(AppRouter.healthCareServicesPage.name);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentReactionsPage(appointmentId: "1", allergyId: "1")));

                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'favorites',
                    child: ListTile(
                      leading: Icon(Icons.favorite_border),
                      title: Text('Favorites'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'services',
                    child: ListTile(
                      leading: Icon(Icons.health_and_safety),
                      title: Text('Health services'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'encounter',
                    child: ListTile(
                      leading: Icon(Icons.health_and_safety),
                      title: Text('encounter services'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reaction',
                    child: ListTile(
                      leading: Icon(Icons.health_and_safety),
                      title: Text('reaction services'),
                    ),
                  ),

                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

}
