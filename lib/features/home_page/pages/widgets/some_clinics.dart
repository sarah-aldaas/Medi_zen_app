import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';

import '../../../../base/go_router/go_router.dart';
import '../../../../base/theme/app_color.dart';
import '../../../clinics/pages/mixin/clinic_mixin.dart';

class SomeClinics extends StatelessWidget with ClinicListMixin {
  SomeClinics({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Some Clinics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouter.clinics.name);
                },
                child: Text("See all",
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: someClinics.map((clinic) {
              return Container(
                width: context.width / 2,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(clinic.imageUrl, fit: BoxFit.fill)),
                    Gap(10),
                    Text(clinic.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(clinic.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                  Icon(Icons.date_range,
                                      color: Theme.of(context).primaryColor,
                                      size: 10),
                                  Gap(4),
                                  Text(clinic.daysAgo,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 10)),
                                ],
                              ),
                            );
                          },
                        ),
                        Gap(8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.grey, size: 10),
                            Gap(4),
                            Text(clinic.location,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
