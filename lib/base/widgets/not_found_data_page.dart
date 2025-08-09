import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class NotFoundDataPage extends StatelessWidget {
  const NotFoundDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replace with your actual asset path
            Image.asset('assets/images/noData.png', width: 250, height: 250),
            const SizedBox(height: 20),
            Text(
              'NotFoundDataPage.notFound'.tr(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'NotFoundDataPage.checkAgain'.tr(context),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
