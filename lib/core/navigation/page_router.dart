import 'package:flutter/material.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute({
    required RouteSettings settings,
    required Widget page,
    bool isVertical = false,
    bool slideAnimation = true,
  }) : super(
          builder: (context) => page,
        );
}
