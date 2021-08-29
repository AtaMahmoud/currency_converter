import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature of the custom builder method definition
typedef ResponsiveBuilder = Widget Function(
  BuildContext context,
  Size size,
);

/// widget to get the [size] of the available space inside the [SafeAra],
/// down to its children
/// disable the [bottom] padding for iOS devices to avoid home button padding
class ResponsiveSafeArea extends StatelessWidget {
  const ResponsiveSafeArea({
    required ResponsiveBuilder builder,
    Key? key,
  })  : responsiveBuilder = builder,
        super(key: key);

  final ResponsiveBuilder responsiveBuilder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom:!(defaultTargetPlatform == TargetPlatform.iOS),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return responsiveBuilder(
            context,
            constraints.biggest,
          );
        },
      ),
    );
  }
}
