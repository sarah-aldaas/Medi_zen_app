import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';
import '../../../doctor/doctor_screen.dart';

class ClinicCard extends StatelessWidget {
  final String clinicName;
  final String specialization;


  const ClinicCard({super.key,required this.clinicName, required this.specialization});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'assets/clinic.png',
                height: 130,
                width: 120,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40, left: 90),
            child: Card(
              color: AppColors.backgroundColor,
              margin: EdgeInsets.all(2.0),
              child: SizedBox(
                height: 140,
                child: Center(
                  child: ListTile(
                    title: Text(
                      clinicName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      specialization,
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Doctorscreen(),
                          ),
                        );
                      },
                      child: Text(
                        "clinicCard.seeDetails".tr(context),
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
