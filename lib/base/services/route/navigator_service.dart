import 'package:flutter/material.dart';

import '../di/injection_container_common.dart';

class NavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  push(Widget page) {
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => page));
  }

  pop() {
    navigatorKey.currentState?.pop();
  }

  pushWithName(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}

final navigatorService = serviceLocator<NavigatorService>();
