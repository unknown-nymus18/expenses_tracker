import 'dart:ui';

import 'package:flutter/material.dart';

class Blur extends StatelessWidget {
  final double sigmaX;
  final double sigmaY;
  const Blur({super.key, this.sigmaX = 10.0, this.sigmaY = 10.0});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: Container(color: Colors.black.withOpacity(0)),
    );
  }
}
