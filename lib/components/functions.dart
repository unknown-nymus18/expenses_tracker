import 'package:expenses_app/providers/bottom_navbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

void onScroll(ScrollController controller, BuildContext context) {
  controller.addListener(() {
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      Provider.of<BottomNavbarManager>(context, listen: false).stickToBottom();
    } else if (controller.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<BottomNavbarManager>(context, listen: false).makeFloating();
    }
  });
}
