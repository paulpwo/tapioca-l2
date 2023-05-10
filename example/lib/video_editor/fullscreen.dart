import 'package:flutter/material.dart';

class FullScreenWidget extends StatelessWidget {
  final Widget child;
  final Size size;

  FullScreenWidget({required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    final width = size.width;
    final height = size.height;

    // return FittedBox(
    //   fit: BoxFit.cover,
    //   child: SizedBox(
    //     width: width,
    //     height: height,
    //     child: child,
    //   ),
    // );
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
