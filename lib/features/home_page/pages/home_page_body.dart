import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_clinics.dart';

import '../../../main.dart';
import '../../complains/presentation/pages/complain_list_page.dart';
import '../../invoice/presentation/pages/my_appointment_finished_invoice_page.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: SomeClinics()),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: DefinitionWidget()),
              Gap(12),
              // Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: SomeDoctors()),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: SimpleArticlesPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    PatientModel? myPatientModel = loadingPatientModel();
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 20, left: 16, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRouter.profile.name);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child:FlexibleImage(imageUrl:myPatientModel.avatar ,assetPath: "assets/images/person.jpg",) ,
                  ),
                  radius: 20,
                ),
                // AvatarImage(imageUrl: myPatientModel.avatar, radius: 20),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(),
                    Text(
                      "${myPatientModel.fName.toString()} ${myPatientModel.lName.toString()}",

                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
              const SizedBox(width: 16.0),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),

                color: theme.cardColor,
                elevation: 8.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                onSelected: (String value) {
                  if (value == 'services') {
                    context.pushNamed(AppRouter.healthCareServicesPage.name);
                  } else if (value == 'invoice') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppointmentFinishedInvoicePage()));
                  } else if (value == 'complain') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplainListPage()));
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'services',
                        child: ListTile(
                          leading: Icon(Icons.health_and_safety, color: Theme.of(context).primaryColor),

                          title: Text('Health services', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                        ),
                      ),

                      PopupMenuItem<String>(
                        value: 'invoice',
                        child: ListTile(
                          leading: Icon(Icons.paid, color: Theme.of(context).primaryColor),

                          title: Text('Invoices', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'complain',
                        child: ListTile(
                          leading: Icon(Icons.feedback, color: Theme.of(context).primaryColor),

                          title: Text('Complaints', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
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
