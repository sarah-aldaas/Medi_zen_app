import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import '../../../../base/extensions/localization_extensions.dart'; // Add this import
import '../../../../base/go_router/go_router.dart';
import '../../../../base/theme/app_color.dart';
import '../../../doctor/pages/mixin/doctor_mixin.dart';

class SomeDoctors extends StatelessWidget with DoctorMixin {
  SomeDoctors({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "some_doctors.top_doctors".tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouter.doctors.name);
                },
                child: Text(
                  "some_doctors.see_all".tr(context),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topDoctors.map((doctor) {
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DoctorDetailsPage(doctor: doctor),
                  //   ),
                  // );
                },
                child: Card(
                  child: Container(
                    width: context.width / 3,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(doctor.avatar),
                          radius: 30,
                        ),
                        Gap(10),
                        Text(
                          doctor.fName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doctor.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Gap(8),
                        Row(
                          children: [
                            ThemeSwitcher.withTheme(
                              builder: (_, switcher, theme) {
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: theme.brightness == Brightness.light
                                        ? Colors.grey.shade200
                                        : AppColors.backGroundLogo,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Theme.of(context).primaryColor,
                                        size: 10,
                                      ),
                                      Gap(4),
                                      Text(
                                        doctor.id.toString(),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Gap(8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                  size: 10,
                                ),
                                Gap(4),
                                Text(
                                  doctor.address,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}