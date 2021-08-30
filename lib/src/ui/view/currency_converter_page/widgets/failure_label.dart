import 'package:flutter/material.dart';

import '../../../../business_logic/models/failure.dart';
class FailureLabel extends StatelessWidget {
  const FailureLabel({
    Key? key,
    required this.failure,
  }) : super(key: key);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Text(failure.toString(),
        style: themeData.textTheme.subtitle1!.copyWith(
          color: themeData.errorColor,
        ));
  }
}