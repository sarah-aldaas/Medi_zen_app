import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../../../base/constant/app_images.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';
import '../../cubit/clinic.dart';
import '../home_page_body.dart';
import 'clinic_card.dart';

class ClinicsPage extends StatelessWidget {
  List clinics=[];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: ListView.builder(
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              return ClinicCard(
                clinicName: clinics[index].name,
                specialization: clinics[index].details,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 60, left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePageBody(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 100),
                    Text(
                      'clinicsPage.allClinics'.tr(context),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssetImages.clinic1),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Medical center number\n011 611 22 33',
                      style: AppStyles.titleTextStyle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
