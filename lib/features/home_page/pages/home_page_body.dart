import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/my_favorite.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_clinics.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_doctors.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/appointment_reactions_page.dart';

import '../../../main.dart';
import '../../profile/presentaiton/widgets/avatar_image_widget.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final String clinicId =
      "1";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(

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
    PatientModel? myPatientModel =
    loadingPatientModel();
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 20, left: 16, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              context.pushNamed(AppRouter.profile.name);
            },
            child: Row(
              children: [
                AvatarImage(imageUrl: myPatientModel.avatar, radius: 20),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(),
                    Text(
                      "${myPatientModel.fName.toString()} ${myPatientModel.lName.toString()}",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,

                color: theme.iconTheme.color,
              ),
              const SizedBox(width: 16.0),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,

                  color: theme.iconTheme.color,
                ),

                color: theme.cardColor,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected: (String value) {
                  if (value == 'favorites') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyFavorite()),
                    );
                  } else if (value == 'services') {
                    context.pushNamed(AppRouter.healthCareServicesPage.name);
                    // context.pushNamed(AppRouter.allAllergiesPage.name);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'favorites',
                    child: ListTile(
                      leading: Icon(
                        Icons.favorite_border,

                        color: Colors.blue,
                      ),

                      title: Text(
                        'Favorites',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'services',
                    child: ListTile(
                      leading: Icon(
                        Icons.health_and_safety,
                        color: Colors.green,
                      ),

                      title: Text(
                        'Health services',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
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
