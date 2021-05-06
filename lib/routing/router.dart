import 'package:flutter/material.dart';
import 'package:umbrella_manager/pages/home/home.dart';
import 'package:umbrella_manager/routing/router_constants.dart';
import 'package:umbrella_manager/pages/settings/settings.dart';
import 'package:umbrella_manager/tad_widgets/view/tab_bar/tab_bar_controller.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  // ignore: unused_local_variable
  var parameters = settings.arguments as Map<String, dynamic>;
  switch (settings.name) {
    case tabControllerPageRoute:
      return MaterialPageRoute(builder: (context) => TabBarController());
    case homePageRoute:
      return MaterialPageRoute(builder: (context) => HomePage());
    case settingsPageRoute:
      return MaterialPageRoute(builder: (context) => SettingsPage());
    default:
      return MaterialPageRoute(builder: (context) => HomePage());
  }
}
