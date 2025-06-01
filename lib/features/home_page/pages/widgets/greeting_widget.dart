import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String getGreeting(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      return "greetings.morning".tr(context);
    } else if (hour < 18) {
      return "greetings.afternoon".tr(context);
    } else {
      return "greetings.evening".tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(getGreeting(context), style: TextStyle(fontSize: 12));
  }
}
