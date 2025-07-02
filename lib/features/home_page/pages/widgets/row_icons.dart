import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../base/extensions/localization_extensions.dart';
import '../../../../base/go_router/go_router.dart';

class RowIcons extends StatelessWidget {
  const RowIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.doctors.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: const Center(child: Icon(Icons.ac_unit)),
                    ),
                  ),
                  Text("row_icons.doctors".tr(context)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.articles.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: const Center(child: Icon(Icons.article_outlined)),
                    ),
                  ),
                  Text("row_icons.articles".tr(context)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: const Center(child: Icon(Icons.home_repair_service)),
                  ),
                ),
                Text("row_icons.services".tr(context)),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.helpCenter.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: const Center(
                        child: Icon(Icons.help_center_outlined),
                      ),
                    ),
                  ),
                  Text("row_icons.help_center".tr(context)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
